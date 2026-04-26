/// Entity representation for the [comments] table.
class CommentModel {
  final String id;
  final String submissionId;
  final String userId;
  final String commentText;

  CommentModel({
    required this.id,
    required this.submissionId,
    required this.userId,
    required this.commentText,
  });

  /// Maps JSON data from Supabase to the [CommentModel] object.
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      submissionId: json['submission_id'] as String,
      userId: json['user_id'] as String,
      commentText: json['comment_text'] as String,
    );
  }

  /// Converts the [CommentModel] object to a JSON map for Supabase.
  Map<String, dynamic> toJson() {
    return {
      'submission_id': submissionId,
      'user_id': userId,
      'comment_text': commentText,
      'client_created_at': DateTime.now().toIso8601String(),
    };
  }
}
