import 'package:flutter/foundation.dart';
import '../../models/comment_model.dart';
import '../../repositories/comment_repository.dart';

class CommentController extends ChangeNotifier {
  final CommentRepository _repository;

  List<CommentModel> comments = [];
  bool isLoading = false;
  String? errorMessage;

  CommentController(this._repository);

  Future<void> fetchCommentsByPhase(String phaseId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      comments = await _repository.getCommentsByPhaseId(phaseId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCommentsByTask(String taskId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      comments = await _repository.getCommentsByTaskId(taskId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addComment(CommentModel comment) async {
    try {
      final created = await _repository.createComment(comment);
      comments.add(created);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
