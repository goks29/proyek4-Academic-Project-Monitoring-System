import '../services/local/comment_local_service.dart';
import '../services/remote/comment_service.dart';
import '../models/comment_model.dart';

class CommentRepository {
  final CommentService _remote;
  final CommentLocalService _local;

  CommentRepository(this._remote, this._local);

  Future<List<CommentModel>> getCommentsByPhaseId(String phaseId) async {
    final localData = _local.getCommentsByPhaseId(phaseId);
    try {
      final remoteData = await _remote.getCommentsByPhaseId(phaseId);
      await _local.saveAllComments(remoteData);
      return remoteData;
    } catch (e) {
      return localData;
    }
  }

  Future<List<CommentModel>> getCommentsByTaskId(String taskId) async {
    final localData = _local.getCommentsByTaskId(taskId);
    try {
      final remoteData = await _remote.getCommentsByTaskId(taskId);
      await _local.saveAllComments(remoteData);
      return remoteData;
    } catch (e) {
      return localData;
    }
  }

  Future<CommentModel> createComment(CommentModel comment) async {
    final created = await _remote.createComment(comment);
    await _local.saveComment(created);
    return created;
  }
}
