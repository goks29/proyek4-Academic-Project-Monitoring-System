import 'package:hive/hive.dart';
import '../../models/comment_model.dart';

class CommentLocalService {
  final Box<CommentModel> _box;

  CommentLocalService(this._box);

  List<CommentModel> getCommentsByPhaseId(String phaseId) {
    return _box.values.where((c) => c.phaseId == phaseId).toList();
  }

  List<CommentModel> getCommentsByTaskId(String taskId) {
    return _box.values.where((c) => c.taskId == taskId).toList();
  }

  Future<void> saveComment(CommentModel comment) async {
    await _box.put(comment.id, comment);
  }

  Future<void> saveAllComments(List<CommentModel> comments) async {
    final Map<String, CommentModel> commentMap = {
      for (var c in comments) c.id: c
    };
    await _box.putAll(commentMap);
  }

  Future<void> clearComments() async {
    await _box.clear();
  }
}
