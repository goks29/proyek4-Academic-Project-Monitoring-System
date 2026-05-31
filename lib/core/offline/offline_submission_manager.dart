import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/pending_submission_model.dart';
import '../../models/submission_model.dart';
import 'connectivity_monitor.dart';
import 'monotonic_clock_service.dart';
import 'session_token_manager.dart';

/// Orchestrator utama untuk fitur offline submission.
/// 
/// Menangani dua alur:
/// - **Online**: submit langsung ke Supabase (alur existing)
/// - **Offline**: hash file, simpan lokal, estimasi waktu, queue untuk sync
class OfflineSubmissionManager {
  final SupabaseClient _client;
  final ConnectivityMonitor _connectivity;
  final SessionTokenManager _tokenManager;
  final MonotonicClockService _clock;
  final Box<PendingSubmissionModel> _pendingBox;
  final Uuid _uuid = const Uuid();

  OfflineSubmissionManager({
    required SupabaseClient client,
    required ConnectivityMonitor connectivity,
    required SessionTokenManager tokenManager,
    required MonotonicClockService clock,
    required Box<PendingSubmissionModel> pendingBox,
  })  : _client = client,
        _connectivity = connectivity,
        _tokenManager = tokenManager,
        _clock = clock,
        _pendingBox = pendingBox;

  /// Mendapatkan daftar submission yang pending sync.
  List<PendingSubmissionModel> getPendingSubmissions() {
    return _pendingBox.values
        .where((s) => s.syncStatus == 'pending_sync')
        .toList();
  }

  /// Mendapatkan semua pending submissions untuk task tertentu.
  List<PendingSubmissionModel> getPendingByTaskId(String taskId) {
    return _pendingBox.values
        .where((s) => s.taskId == taskId && s.syncStatus == 'pending_sync')
        .toList();
  }

  /// Submit bukti — otomatis memilih alur online atau offline.
  /// 
  /// Returns:
  /// - `SubmissionModel` jika berhasil submit online
  /// - `null` jika disimpan offline (pending sync)
  /// 
  /// Throws jika terjadi error yang tidak bisa di-handle.
  Future<SubmissionModel?> submitEvidence({
    required String taskId,
    required String studentId,
    required XFile file,
    required String notes,
  }) async {
    final isOnline = await _connectivity.checkConnectivity();

    if (isOnline) {
      // Online: coba submit langsung, fallback ke offline jika gagal
      try {
        return await _submitOnline(
          taskId: taskId,
          studentId: studentId,
          file: file,
          notes: notes,
        );
      } catch (e) {
        debugPrint('[OfflineSubmissionManager] Online submit failed, saving offline: $e');
        try {
          await _saveOffline(
            taskId: taskId,
            studentId: studentId,
            file: file,
            notes: notes,
          );
          return null;
        } catch (offlineErr) {
          // Jika gagal offline juga, lempar error online asli agar user tahu masalah sebenarnya!
          throw Exception(
            'Gagal mengirim bukti secara online: $e.\n'
            'Upaya penyimpanan offline juga gagal karena: $offlineErr'
          );
        }
      }
    } else {
      // Offline: simpan lokal
      await _saveOffline(
        taskId: taskId,
        studentId: studentId,
        file: file,
        notes: notes,
      );
      return null;
    }
  }

  /// Upload dan submit langsung ke Supabase (alur online).
  Future<SubmissionModel> _submitOnline({
    required String taskId,
    required String studentId,
    required XFile file,
    required String notes,
  }) async {
    final bytes = await file.readAsBytes();
    final ext = file.name.split('.').last.toLowerCase();
    final fileName = '$taskId/${_uuid.v4()}.$ext';
    final mimeType = file.mimeType ?? _mimeFromExt(ext);

    // 1. Upload ke Storage
    await _client.storage.from('task-evidence').uploadBinary(
      fileName,
      bytes,
      fileOptions: FileOptions(
        contentType: mimeType,
        upsert: false,
      ),
    );

    // 2. Generate signed URL
    final evidenceUrl = await _client.storage
        .from('task-evidence')
        .createSignedUrl(fileName, 60 * 60 * 24 * 365);

    // 3. Hash file
    final fileHash = sha256.convert(bytes).toString();

    // 4. Insert submission
    final now = DateTime.now();
    final payload = {
      'task_id': taskId,
      'student_id': studentId,
      'submitted_at': now.toIso8601String(),
      'evidence_file_url': evidenceUrl,
      'student_notes': notes.trim().isEmpty ? null : notes.trim(),
      'status': 'pending',
      'file_hash': fileHash,
      'sync_status': 'direct',
    };

    final response = await _client
        .from('submissions')
        .insert(payload)
        .select()
        .single();

    return SubmissionModel.fromJson(response);
  }

  /// Simpan submission secara offline ke Hive + file system lokal.
  Future<void> _saveOffline({
    required String taskId,
    required String studentId,
    required XFile file,
    required String notes,
  }) async {
    // 1. Ambil/validasi session token
    final token = await _tokenManager.getValidToken();
    if (token == null) {
      throw Exception(
        'Tidak ada session token yang valid. '
        'Anda perlu online terlebih dahulu untuk mendapatkan token.'
      );
    }

    // 2. Baca file dan hash
    final bytes = await file.readAsBytes();
    final fileHash = sha256.convert(bytes).toString();

    // 3. Simpan file ke app directory
    final appDir = await getApplicationDocumentsDirectory();
    final offlineDir = Directory('${appDir.path}/offline_submissions');
    if (!await offlineDir.exists()) {
      await offlineDir.create(recursive: true);
    }
    
    final ext = file.name.split('.').last.toLowerCase();
    final localFileName = '${_uuid.v4()}.$ext';
    final localFile = File('${offlineDir.path}/$localFileName');
    await localFile.writeAsBytes(bytes);

    // 4. Hitung estimasi waktu submit
    final monotonicNow = await _clock.getElapsedRealtime();
    final estimatedSubmitAt = token.estimateCurrentTime(monotonicNow);

    // 5. Generate nonce
    final syncNonce = _uuid.v4();

    // 6. Simpan ke Hive
    final pending = PendingSubmissionModel(
      id: _uuid.v4(),
      taskId: taskId,
      studentId: studentId,
      localFilePath: localFile.path,
      fileHash: fileHash,
      estimatedSubmitAt: estimatedSubmitAt,
      syncNonce: syncNonce,
      notes: notes.trim().isEmpty ? null : notes.trim(),
      fileName: file.name,
      mimeType: file.mimeType ?? _mimeFromExt(ext),
      tokenUserId: token.userId,
      tokenDeviceId: token.deviceId,
      tokenServerTime: token.serverTime,
      tokenMonotonicAtIssue: token.monotonicAtIssue,
      tokenExpiresAt: token.expiresAt,
      tokenSignature: token.signature,
      createdAt: DateTime.now(),
    );

    await _pendingBox.put(pending.id, pending);
    debugPrint('[OfflineSubmissionManager] Submission saved offline: ${pending.id}');
  }

  /// Sync satu pending submission ke server.
  /// Dipanggil oleh SyncManager saat online.
  Future<bool> syncSubmission(PendingSubmissionModel pending) async {
    try {
      // 1. Update status
      pending.syncStatus = 'syncing';
      await pending.save();

      // 2. Baca file lokal
      final localFile = File(pending.localFilePath);
      if (!await localFile.exists()) {
        pending.syncStatus = 'rejected';
        pending.syncError = 'File lokal tidak ditemukan';
        await pending.save();
        return false;
      }
      final bytes = await localFile.readAsBytes();

      // 3. Verify hash masih sama
      final currentHash = sha256.convert(bytes).toString();
      if (currentHash != pending.fileHash) {
        pending.syncStatus = 'rejected';
        pending.syncError = 'File hash mismatch — file mungkin terkorupsi';
        await pending.save();
        return false;
      }

      // 4. Upload file ke Supabase Storage
      final ext = pending.fileName.split('.').last.toLowerCase();
      final storagePath = '${pending.taskId}/${_uuid.v4()}.$ext';

      await _client.storage.from('task-evidence').uploadBinary(
        storagePath,
        bytes,
        fileOptions: FileOptions(
          contentType: pending.mimeType,
          upsert: false,
        ),
      );

      final evidenceUrl = await _client.storage
          .from('task-evidence')
          .createSignedUrl(storagePath, 60 * 60 * 24 * 365);

      // 5. Call RPC verify_offline_submission
      final result = await _client.rpc('verify_offline_submission', params: {
        'p_task_id': pending.taskId,
        'p_student_id': pending.studentId,
        'p_evidence_file_url': evidenceUrl,
        'p_student_notes': pending.notes,
        'p_file_hash': pending.fileHash,
        'p_estimated_submit_at': pending.estimatedSubmitAt.toIso8601String(),
        'p_sync_nonce': pending.syncNonce,
        'p_token_user_id': pending.tokenUserId,
        'p_token_device_id': pending.tokenDeviceId,
        'p_token_server_time': pending.tokenServerTime.toIso8601String(),
        'p_token_monotonic_at_issue': pending.tokenMonotonicAtIssue,
        'p_token_expires_at': pending.tokenExpiresAt.toIso8601String(),
        'p_token_signature': pending.tokenSignature,
      });

      final resultMap = Map<String, dynamic>.from(result as Map);
      final status = resultMap['status'] as String;

      if (status == 'synced') {
        pending.syncStatus = 'synced';
        await pending.save();

        // Hapus file lokal setelah berhasil sync
        if (await localFile.exists()) {
          await localFile.delete();
        }
        debugPrint('[OfflineSubmissionManager] Sync berhasil: ${pending.id}');
        return true;
      } else {
        pending.syncStatus = 'rejected';
        pending.syncError = resultMap['reason'] as String?;
        await pending.save();
        debugPrint('[OfflineSubmissionManager] Sync ditolak: ${resultMap['reason']}');
        return false;
      }
    } catch (e) {
      pending.syncStatus = 'pending_sync';
      pending.retryCount++;
      pending.syncError = e.toString();
      await pending.save();
      debugPrint('[OfflineSubmissionManager] Sync error: $e');
      return false;
    }
  }

  /// Sync semua pending submissions.
  Future<void> syncAllPending() async {
    final pendingList = getPendingSubmissions();
    if (pendingList.isEmpty) return;

    debugPrint('[OfflineSubmissionManager] Syncing ${pendingList.length} pending submissions...');
    
    for (final pending in pendingList) {
      // Skip jika sudah terlalu banyak retry
      if (pending.retryCount >= 5) {
        debugPrint('[OfflineSubmissionManager] Skipping ${pending.id} — too many retries');
        continue;
      }
      
      await syncSubmission(pending);
    }
  }

  /// Hapus pending submission (misalnya setelah user membatalkan).
  Future<void> removePending(String id) async {
    final pending = _pendingBox.get(id);
    if (pending != null) {
      // Hapus file lokal
      final localFile = File(pending.localFilePath);
      if (await localFile.exists()) {
        await localFile.delete();
      }
      await _pendingBox.delete(id);
    }
  }

  String _mimeFromExt(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'image/jpeg';
    }
  }
}
