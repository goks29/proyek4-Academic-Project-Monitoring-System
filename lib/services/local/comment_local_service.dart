import 'package:hive/hive.dart';
import '../../models/comment_model.dart';

// Local service for comments table
class CommentLocalService {
  final Box<CommentModel> _box;

  CommentLocalService(this._box);

  List<CommentModel> getCommentsBySubmissionId(String submissionId) {
    return _box.values.where((comment) => comment.submissionId == submissionId).toList();
  }

  Future<void> saveComment(CommentModel comment) async {
    await _box.put(comment.id, comment);
    print('Comment ${comment.id} saved to local storage.');
  }

  Future<void> saveAllComments(List<CommentModel> comments) async {
    final Map<String, CommentModel> commentMap = {
      for (var c in comments) c.id: c
    };
    await _box.putAll(commentMap);
    print('${comments.length} comments saved to local storage.');
  }

  Future<void> clearComments() async {
    await _box.clear();
  }
}
