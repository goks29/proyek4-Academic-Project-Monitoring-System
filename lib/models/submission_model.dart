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
  final String phaseId;

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

  /// ID task_allocation yang dikaitkan dengan submission ini.
  /// Tidak disimpan ke Hive (transient), diisi saat fetch dari cloud.
  final String? taskId;

  SubmissionModel({
    required this.id,
    required this.phaseId,
    required this.studentId,
    required this.submittedAt,
    this.evidenceFileUrl,
    this.studentNotes,
    required this.status,
    this.lecturerFeedback,
    this.lecturerId,
    this.serverReceivedAt,
    this.taskId,
  });

  /// Membuat instance SubmissionModel dari format JSON Supabase.
  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'] as String,
      phaseId: json['phase_id'] as String,
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
      taskId: json['task_id'] as String?,
    );
  }

  /// Mengonversi instance SubmissionModel ke format JSON untuk Supabase.
  Map<String, dynamic> toJson() {
    return {
      'phase_id': phaseId,
      'student_id': studentId,
      'submitted_at': submittedAt.toIso8601String(),
      'evidence_file_url': evidenceFileUrl,
      'student_notes': studentNotes,
      'status': status,
      'lecturer_feedback': lecturerFeedback,
      'lecturer_id': lecturerId,
      if (taskId != null) 'task_id': taskId,
    };
  }
}
