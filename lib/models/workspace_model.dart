import 'package:hive/hive.dart';

/*
 * Tabel: workspaces
 * Operasi & Aturan Bisnis:
 * - SELECT: Dapat diakses oleh anggota kelompok dan dosen proyek terkait guna memfasilitasi transparansi kerja dan pemantauan progres internal kelompok.
 * - INSERT: Dapat dilakukan oleh seluruh mahasiswa yang terautentikasi untuk membentuk kelompok baru sebelum bergabung ke proyek mana pun.
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
  final String? joinCode;

  @HiveField(2)
  final String teamName;

  @HiveField(3)
  final String topicName;

  @HiveField(4)
  final String? topicDescription;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final String? lecturerFeedback;

  @HiveField(7)
  final bool isCompleted;

  @HiveField(8)
  final DateTime clientCreatedAt;

  @HiveField(9)
  final DateTime? serverReceivedAt;

  WorkspaceModel({
    required this.id,
    this.joinCode,
    required this.teamName,
    required this.topicName,
    this.topicDescription,
    required this.status,
    this.lecturerFeedback,
    this.isCompleted = false,
    required this.clientCreatedAt,
    this.serverReceivedAt,
  });

  /// Membuat instance WorkspaceModel dari format JSON Supabase.
  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      id: json['id'] as String,
      joinCode: json['join_code'] as String?,
      teamName: json['team_name'] as String,
      topicName: json['topic_name'] as String? ?? '',
      topicDescription: json['topic_description'] as String?,
      status: json['status'] as String? ?? 'pending',
      lecturerFeedback: json['lecturer_feedback'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      clientCreatedAt: DateTime.parse(json['client_created_at'] as String),
      serverReceivedAt: json['server_received_at'] != null 
          ? DateTime.parse(json['server_received_at'] as String) 
          : null,
    );
  }

  /// Mengonversi instance WorkspaceModel ke format JSON untuk Supabase.
  Map<String, dynamic> toJson() {
    return {
      'join_code': joinCode,
      'team_name': teamName,
      'topic_name': topicName,
      'topic_description': topicDescription,
      'status': status,
      'lecturer_feedback': lecturerFeedback,
      'is_completed': isCompleted,
      'client_created_at': clientCreatedAt.toIso8601String(),
    };
  }
}
