import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/comment_model.dart';

// Service untuk operasi tabel comments di Supabase
/// Layanan untuk berinteraksi dengan tabel 'comments' di Supabase.
class CommentService {
  final SupabaseClient _client;

  CommentService(this._client);

  // Ambil komentar untuk submission tertentu
  /// Mengambil komentar untuk submission tertentu, diurutkan dari yang terlama.
  Future<List<CommentModel>> getComments(String submissionId) async {
    final response = await _client
        .from('comments')
        .select()
        .eq('submission_id', submissionId)
        .order('client_created_at', ascending: true);
        
    return (response as List<dynamic>)
        .map((json) => CommentModel.fromJson(json))
        .toList();
  }

  // Tambah komentar baru
  /// Menambahkan komentar baru ke dalam database cloud.
  Future<CommentModel> createComment(CommentModel comment) async {
    final response = await _client
        .from('comments')
        .insert(comment.toJson())
        .select()
        .single();
    return CommentModel.fromJson(response);
  }
}
