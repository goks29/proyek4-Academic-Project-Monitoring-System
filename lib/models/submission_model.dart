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
  final String submittedAt;

  @HiveField(4)
  final String? evidenceFileUrl;

  @HiveField(5)
  final String? studentNotes;

  @HiveField(6)
  final String status;

  @HiveField(7)
  final String? lecturerFeedback;

  SubmissionModel({
    required this.id,
    required this.phaseId,
    required this.studentId,
    required this.submittedAt,
    this.evidenceFileUrl,
    this.studentNotes,
    required this.status,
    this.lecturerFeedback,
  });

  /// Membuat instance SubmissionModel dari format JSON Supabase.
  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'] as String,
      phaseId: json['phase_id'] as String,
      studentId: json['student_id'] as String,
      submittedAt: json['submitted_at'] as String,
      evidenceFileUrl: json['evidence_file_url'] as String?,
      studentNotes: json['student_notes'] as String?,
      status: json['status'] as String,
      lecturerFeedback: json['lecturer_feedback'] as String?,
    );
  }

  /// Mengonversi instance SubmissionModel ke format JSON untuk Supabase.
  Map<String, dynamic> toJson() {
    return {
      'phase_id': phaseId,
      'student_id': studentId,
      'submitted_at': submittedAt,
      'evidence_file_url': evidenceFileUrl,
      'student_notes': studentNotes,
    };
  }
}
