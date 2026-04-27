import 'package:hive/hive.dart';

/*
 * Tabel: workspaces
 * Operasi & Aturan Bisnis:
 * - SELECT: Dapat diakses oleh anggota kelompok dan dosen proyek terkait guna memfasilitasi transparansi kerja dan pemantauan progres internal kelompok.
 * - INSERT: Dapat dilakukan oleh seluruh mahasiswa yang terautentikasi saat proses bergabung ke dalam proyek sebagai bentuk mekanisme pendaftaran kelompok secara mandiri.
 * - UPDATE: Terbatas hanya untuk ketua kelompok atau dosen proyek terkait guna memastikan bahwa perubahan data strategis (seperti topik proyek) dikoordinasikan melalui satu pintu otoritas.
 * - DELETE: Tidak diizinkan melalui akses klien untuk mencegah hilangnya rekam jejak akademik kelompok secara tidak sengaja.
 */

part 'workspace_model.g.dart';

/// Model data yang merepresentasikan tabel 'workspaces' di database.
@HiveType(typeId: 6)
class WorkspaceModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String projectId;

  @HiveField(2)
  final String teamName;

  @HiveField(3)
  final String topicName;

  @HiveField(4)
  final String progressionMode;

  WorkspaceModel({
    required this.id,
    required this.projectId,
    required this.teamName,
    required this.topicName,
    required this.progressionMode,
  });

  /// Membuat instance WorkspaceModel dari format JSON Supabase.
  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      teamName: json['team_name'] as String,
      topicName: json['topic_name'] as String? ?? '',
      progressionMode: json['progression_mode'] as String,
    );
  }

  /// Mengonversi instance WorkspaceModel ke format JSON untuk Supabase.
  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'team_name': teamName,
      'topic_name': topicName,
      'progression_mode': progressionMode,
      'client_created_at': DateTime.now().toIso8601String(),
    };
  }
}
