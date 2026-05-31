import 'package:hive/hive.dart';

part 'pending_submission_model.g.dart';

/// Model untuk submission yang dibuat saat offline dan belum di-sync ke server.
/// Menyimpan file secara lokal beserta semua metadata yang diperlukan untuk
/// verifikasi saat sync (hash, nonce, token, estimasi waktu).
@HiveType(typeId: 10)
class PendingSubmissionModel extends HiveObject {
  @HiveField(0)
  final String id; // UUID yang di-generate di client

  @HiveField(1)
  final String taskId;

  @HiveField(2)
  final String studentId;

  @HiveField(3)
  final String localFilePath; // Path file di app directory

  @HiveField(4)
  final String fileHash; // SHA-256 hash dari file

  @HiveField(5)
  final DateTime estimatedSubmitAt; // Estimasi waktu submit dari monotonic clock

  @HiveField(6)
  final String syncNonce; // UUID unik anti-replay

  @HiveField(7)
  final String? notes; // Catatan mahasiswa

  @HiveField(8)
  final String fileName; // Nama file asli (untuk upload)

  @HiveField(9)
  final String mimeType; // MIME type file

  // Session token fields (disimpan flat untuk kemudahan Hive serialization)
  @HiveField(10)
  final String tokenUserId;

  @HiveField(11)
  final String tokenDeviceId;

  @HiveField(12)
  final DateTime tokenServerTime;

  @HiveField(13)
  final int tokenMonotonicAtIssue;

  @HiveField(14)
  final DateTime tokenExpiresAt;

  @HiveField(15)
  final String tokenSignature;

  @HiveField(16)
  final DateTime createdAt;

  @HiveField(17)
  String syncStatus; // 'pending_sync', 'syncing', 'synced', 'rejected'

  @HiveField(18)
  String? syncError; // Pesan error jika sync gagal

  @HiveField(19)
  int retryCount;

  PendingSubmissionModel({
    required this.id,
    required this.taskId,
    required this.studentId,
    required this.localFilePath,
    required this.fileHash,
    required this.estimatedSubmitAt,
    required this.syncNonce,
    this.notes,
    required this.fileName,
    required this.mimeType,
    required this.tokenUserId,
    required this.tokenDeviceId,
    required this.tokenServerTime,
    required this.tokenMonotonicAtIssue,
    required this.tokenExpiresAt,
    required this.tokenSignature,
    required this.createdAt,
    this.syncStatus = 'pending_sync',
    this.syncError,
    this.retryCount = 0,
  });
}
