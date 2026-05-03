import 'package:hive/hive.dart';

/*
 * Tabel: comments
 * Operasi & Aturan Bisnis:
 * - SELECT / INSERT / UPDATE / DELETE: Memiliki akses penuh bagi seluruh anggota kelompok yang bersangkutan serta dosen proyek terkait karena tabel ini secara eksklusif difungsikan sebagai ruang diskusi, bimbingan, dan komunikasi kolaboratif yang memerlukan partisipasi dua arah.
 */

part 'comment_model.g.dart';

/// Model data yang merepresentasikan tabel 'comments' di database.
@HiveType(typeId: 4)
class CommentModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? phaseId;

  @HiveField(2)
  final String? taskId;

  @HiveField(3)
  final String userId;

  @HiveField(4)
  final String commentText;

  @HiveField(5)
  final DateTime clientCreatedAt;

  @HiveField(6)
  final DateTime? serverReceivedAt;

  CommentModel({
    required this.id,
    this.phaseId,
    this.taskId,
    required this.userId,
    required this.commentText,
    required this.clientCreatedAt,
    this.serverReceivedAt,
  });

  /// Membuat instance CommentModel dari format JSON Supabase.
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      phaseId: json['phase_id'] as String?,
      taskId: json['task_id'] as String?,
      userId: json['user_id'] as String,
      commentText: json['comment_text'] as String,
      clientCreatedAt: DateTime.parse(json['client_created_at'] as String),
      serverReceivedAt: json['server_received_at'] != null 
          ? DateTime.parse(json['server_received_at'] as String) 
          : null,
    );
  }

  /// Mengonversi instance CommentModel ke format JSON untuk Supabase.
  Map<String, dynamic> toJson() {
    return {
      'phase_id': phaseId,
      'task_id': taskId,
      'user_id': userId,
      'comment_text': commentText,
      'client_created_at': clientCreatedAt.toIso8601String(),
    };
  }
}
