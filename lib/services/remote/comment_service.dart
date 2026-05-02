import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/comment_model.dart';

class CommentService {
  final SupabaseClient _client;

  CommentService(this._client);

  Future<List<CommentModel>> getCommentsByPhaseId(String phaseId) async {
    final response = await _client
        .from('comments')
        .select()
        .eq('phase_id', phaseId)
        .order('client_created_at', ascending: true);
    return (response as List<dynamic>)
        .map((json) => CommentModel.fromJson(json))
        .toList();
  }

  Future<List<CommentModel>> getCommentsByTaskId(String taskId) async {
    final response = await _client
        .from('comments')
        .select()
        .eq('task_id', taskId)
        .order('client_created_at', ascending: true);
    return (response as List<dynamic>)
        .map((json) => CommentModel.fromJson(json))
        .toList();
  }

  Future<CommentModel> createComment(CommentModel comment) async {
    final response = await _client
        .from('comments')
        .insert(comment.toJson())
        .select()
        .single();
    return CommentModel.fromJson(response);
  }
}
