import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/submission_model.dart';

/// Layanan untuk berinteraksi dengan tabel 'submissions' dan Supabase Storage.
class SubmissionService {
  final SupabaseClient _client;
  static const _bucket = 'task-evidence';

  SubmissionService(this._client);


  Future<List<SubmissionModel>> getSubmissionsByTaskId(String taskId) async {
    final response = await _client
        .from('submissions')
        .select()
        .eq('task_id', taskId);
    return (response as List<dynamic>)
        .map((json) => SubmissionModel.fromJson(json))
        .toList();
  }

  /// Mengambil riwayat submission berdasarkan task_id, urut terbaru dulu.
  Future<List<SubmissionModel>> getSubmissionsByTask(String taskId) async {
    final response = await _client
        .from('submissions')
        .select()
        .eq('task_id', taskId)
        .order('submitted_at', ascending: false);
    return (response as List<dynamic>)
        .map((json) => SubmissionModel.fromJson(json))
        .toList();
  }

  /// Menentukan MIME type dari ekstensi file.
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
        return 'image/jpeg'; // default ke jpeg jika tidak dikenali
    }
  }

  /// Upload file bukti ke Supabase Storage lalu insert record ke tabel submissions.
  /// Mengembalikan [SubmissionModel] yang tersimpan di cloud.
  Future<SubmissionModel> uploadEvidenceAndSubmit({
    required String taskId,
    required String studentId,
    required XFile file,
    required String notes,
  }) async {
    // 1. Upload file ke bucket 'task-evidence'
    final bytes = await file.readAsBytes();
    final ext = file.name.split('.').last.toLowerCase();
    final fileName = '$taskId/${const Uuid().v4()}.$ext';
    final mimeType = file.mimeType ?? _mimeFromExt(ext);

    await _client.storage.from(_bucket).uploadBinary(
      fileName,
      bytes,
      fileOptions: FileOptions(
        contentType: mimeType,
        upsert: false,
      ),
    );

    // Gunakan signed URL (berlaku 1 tahun) agar kompatibel dengan bucket private
    final evidenceUrl = await _client.storage
        .from(_bucket)
        .createSignedUrl(fileName, 60 * 60 * 24 * 365);

    // 2. Insert submission dengan URL file
    final now = DateTime.now();
    final payload = {
      'task_id': taskId,
      'student_id': studentId,
      'submitted_at': now.toIso8601String(),
      'evidence_file_url': evidenceUrl,
      'student_notes': notes.trim().isEmpty ? null : notes.trim(),
      'status': 'pending',
    };

    final response = await _client
        .from('submissions')
        .insert(payload)
        .select()
        .single();

    return SubmissionModel.fromJson(response);
  }

  Future<SubmissionModel> createSubmission(SubmissionModel submission) async {
    final response = await _client
        .from('submissions')
        .insert(submission.toJson())
        .select()
        .single();
    return SubmissionModel.fromJson(response);
  }

  /// Memperbarui status kelulusan dan catatan feedback dari dosen.
  Future<void> updateStatus(
      String submissionId, String status, String feedback) async {
    await _client
        .from('submissions')
        .update({'status': status, 'lecturer_feedback': feedback})
        .eq('id', submissionId);
  }

  Future<void> updateSubmissionReview(String submissionId, String status, String feedback, String lecturerId) async {
    await _client
        .from('submissions')
        .update({
          'status': status,
          'lecturer_feedback': feedback,
          'lecturer_id': lecturerId,
        })
        .eq('id', submissionId);
  }
}
