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
  final String joinCode;

  @HiveField(1)
  final String lecturerId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String? finalSubmissionInfo;

  @HiveField(5)
  final bool isActive;

  @HiveField(6)
  final DateTime createdAt;

  ProjectModel({
    required this.joinCode,
    required this.lecturerId,
    required this.title,
    required this.description,
    this.finalSubmissionInfo,
    this.isActive = true,
    required this.createdAt,
  });

  /// Membuat instance ProjectModel dari format JSON Supabase.
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      joinCode: json['join_code'] as String,
      lecturerId: json['lecturer_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      finalSubmissionInfo: json['final_submission_info'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  /// Mengonversi instance ProjectModel ke format JSON untuk Supabase.
  Map<String, dynamic> toJson() {
    return {
      'join_code': joinCode,
      'lecturer_id': lecturerId,
      'title': title,
      'description': description,
      'final_submission_info': finalSubmissionInfo,
      'is_active': isActive,
    };
  }
}
