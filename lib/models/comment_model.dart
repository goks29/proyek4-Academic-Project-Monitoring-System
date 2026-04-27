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
  final String submissionId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final String commentText;

  CommentModel({
    required this.id,
    required this.submissionId,
    required this.userId,
    required this.commentText,
  });

  /// Membuat instance CommentModel dari format JSON Supabase.
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      submissionId: json['submission_id'] as String,
      userId: json['user_id'] as String,
      commentText: json['comment_text'] as String,
    );
  }

  /// Mengonversi instance CommentModel ke format JSON untuk Supabase.
  Map<String, dynamic> toJson() {
    return {
      'submission_id': submissionId,
      'user_id': userId,
      'comment_text': commentText,
      'client_created_at': DateTime.now().toIso8601String(),
    };
  }
}
