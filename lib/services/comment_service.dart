import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';

/// Service handling operations for the [comments] table.
///
/// Row Level Security (RLS) Rules:
/// - SELECT / INSERT / UPDATE / DELETE: Full access for all members of the respective team and the project lecturer for discussion purposes.
class CommentService {
  final SupabaseClient _client;

  CommentService(this._client);

  /// Fetches all comments for a specific [submissionId], ordered by [client_created_at].
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

  /// Adds a new comment to a submission.
  ///
  /// Allowed for workspace members and the project lecturer.
  Future<CommentModel> createComment(CommentModel comment) async {
    final response = await _client
        .from('comments')
        .insert(comment.toJson())
        .select()
        .single();
    return CommentModel.fromJson(response);
  }
}
