import 'package:hive/hive.dart';

/*
 * Tabel: workspace_members
 * Operasi & Aturan Bisnis:
 * - SELECT: Dapat diakses oleh anggota kelompok dan dosen proyek terkait karena struktur keanggotaan diperlukan untuk kelancaran koordinasi tim dan penilaian akhir dosen.
 * - INSERT: Terbatas hanya untuk ketua kelompok guna memusatkan kendali rekrutmen atau penambahan anggota baru di bawah persetujuan pimpinan kelompok.
 * - UPDATE / DELETE: Tidak diizinkan melalui akses klien guna mengunci keanggotaan agar tidak terjadi manipulasi data anggota di tengah berjalannya proyek.
 */

part 'workspace_member_model.g.dart';

/// Model data yang merepresentasikan tabel 'workspace_members' di database.
@HiveType(typeId: 7)
class WorkspaceMemberModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String workspaceId;

  @HiveField(2)
  final String studentId;

  @HiveField(3)
  final bool isLeader;

  WorkspaceMemberModel({
    required this.id,
    required this.workspaceId,
    required this.studentId,
    required this.isLeader,
  });

  /// Membuat instance WorkspaceMemberModel dari format JSON Supabase.
  factory WorkspaceMemberModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceMemberModel(
      id: json['id'] as String,
      workspaceId: json['workspace_id'] as String,
      studentId: json['student_id'] as String,
      isLeader: json['is_leader'] as bool? ?? false,
    );
  }

  /// Mengonversi instance WorkspaceMemberModel ke format JSON untuk Supabase.
  Map<String, dynamic> toJson() {
    return {
      'workspace_id': workspaceId,
      'student_id': studentId,
      'is_leader': isLeader,
    };
  }
}
