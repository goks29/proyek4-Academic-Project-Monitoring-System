import 'package:hive/hive.dart';

/*
 * Tabel: projects
 * Operasi & Aturan Bisnis:
 * - SELECT: Dapat diakses oleh dosen pemilik proyek dan mahasiswa yang telah bergabung dalam kelompok pada proyek tersebut agar informasi akademik dan instruksi tugas hanya terekspos kepada pihak yang memiliki kepentingan langsung.
 * - INSERT / UPDATE / DELETE: Terbatas hanya untuk dosen pemilik proyek karena dosen merupakan pemegang otoritas tunggal dalam mendefinisikan, mengubah, atau menghapus parameter tugas besar.
 */

part 'project_model.g.dart';

/// Model data yang merepresentasikan tabel 'projects' di database.
@HiveType(typeId: 0)
class ProjectModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String lecturerId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String joinCode;

  @HiveField(5)
  final String? finalSubmissionInfo;

  @HiveField(6)
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.lecturerId,
    required this.title,
    required this.description,
    required this.joinCode,
    this.finalSubmissionInfo,
    required this.createdAt,
  });

  /// Membuat instance ProjectModel dari format JSON Supabase.
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      lecturerId: json['lecturer_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      joinCode: json['join_code'] as String,
      finalSubmissionInfo: json['final_submission_info'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  /// Mengonversi instance ProjectModel ke format JSON untuk Supabase.
  Map<String, dynamic> toJson() {
    return {
      'lecturer_id': lecturerId,
      'title': title,
      'description': description,
      'join_code': joinCode,
      'final_submission_info': finalSubmissionInfo,
    };
  }
}
