import 'package:hive/hive.dart';

/*
 * Tabel: submissions
 * Operasi & Aturan Bisnis:
 * - SELECT: Dapat diakses oleh anggota kelompok dan dosen proyek terkait sebagai wadah transparansi hasil kerja (deliverables) yang telah diselesaikan.
 * - INSERT: Dapat dilakukan oleh seluruh anggota kelompok karena setiap individu berhak mengunggah berkas hasil kerjanya masing-masing sebagai bukti kontribusi.
 * - UPDATE: Terbatas untuk mahasiswa pengunggah dokumen tersebut dan dosen proyek terkait, untuk memastikan bahwa berkas hanya dapat dikoreksi oleh pembuatnya atau dinilai oleh dosen, serta melindunginya dari modifikasi oleh rekan kelompok lain.
 * - DELETE: Tidak diizinkan melalui akses klien guna menjaga integritas bukti pengumpulan tugas.
 */

part 'submission_model.g.dart';

/// Model data yang merepresentasikan tabel 'submissions' di database.
@HiveType(typeId: 3)
class SubmissionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String taskId;

  @HiveField(2)
  final String studentId;

  @HiveField(3)
  final DateTime submittedAt;

  @HiveField(4)
  final String? evidenceFileUrl;

  @HiveField(5)
  final String? studentNotes;

  @HiveField(6)
  final String status;

  @HiveField(7)
  final String? lecturerFeedback;

  @HiveField(8)
  final String? lecturerId;

  @HiveField(9)
  final DateTime? serverReceivedAt;

  @HiveField(10)
  final String? fileHash;

  @HiveField(11)
  final DateTime? estimatedSubmitAt;

  @HiveField(12)
  final String? syncNonce;

  @HiveField(13, defaultValue: 'direct')
  final String syncStatus; // 'direct', 'pending_sync', 'synced', 'rejected'

  SubmissionModel({
    required this.id,
    required this.taskId,
    required this.studentId,
    required this.submittedAt,
    this.evidenceFileUrl,
    this.studentNotes,
    required this.status,
    this.lecturerFeedback,
    this.lecturerId,
    this.serverReceivedAt,
    this.fileHash,
    this.estimatedSubmitAt,
    this.syncNonce,
    this.syncStatus = 'direct',
  });

  /// Membuat instance SubmissionModel dari format JSON Supabase.
  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      studentId: json['student_id'] as String,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      evidenceFileUrl: json['evidence_file_url'] as String?,
      studentNotes: json['student_notes'] as String?,
      status: json['status'] as String,
      lecturerFeedback: json['lecturer_feedback'] as String?,
      lecturerId: json['lecturer_id'] as String?,
      serverReceivedAt: json['server_received_at'] != null 
          ? DateTime.parse(json['server_received_at'] as String) 
          : null,
      fileHash: json['file_hash'] as String?,
      estimatedSubmitAt: json['estimated_submit_at'] != null
          ? DateTime.parse(json['estimated_submit_at'] as String)
          : null,
      syncNonce: json['sync_nonce'] as String?,
      syncStatus: json['sync_status'] as String? ?? 'direct',
    );
  }

  /// Mengonversi instance SubmissionModel ke format JSON untuk Supabase.
  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'student_id': studentId,
      'submitted_at': submittedAt.toIso8601String(),
      'evidence_file_url': evidenceFileUrl,
      'student_notes': studentNotes,
      'status': status,
      'lecturer_feedback': lecturerFeedback,
      'lecturer_id': lecturerId,
      if (fileHash != null) 'file_hash': fileHash,
      if (estimatedSubmitAt != null) 'estimated_submit_at': estimatedSubmitAt!.toIso8601String(),
      if (syncNonce != null) 'sync_nonce': syncNonce,
      'sync_status': syncStatus,
    };
  }
}
