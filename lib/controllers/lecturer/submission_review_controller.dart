import 'package:flutter/foundation.dart';
import '../../models/submission_model.dart';
import '../../repositories/submission_repository.dart';

class SubmissionReviewController extends ChangeNotifier {
  final SubmissionRepository _repository;

  List<SubmissionModel> submissions = [];
  bool isLoading = false;
  String? errorMessage;

  SubmissionReviewController(this._repository);

  Future<void> fetchSubmissions(String taskId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      submissions = await _repository.getSubmissionsByTaskId(taskId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reviewSubmission(String submissionId, String status, String feedback, String lecturerId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.reviewSubmission(submissionId, status, feedback, lecturerId);

      final index = submissions.indexWhere((s) => s.id == submissionId);
      if (index != -1) {
        submissions[index] = SubmissionModel(
          id: submissions[index].id,
          taskId: submissions[index].taskId,
          studentId: submissions[index].studentId,
          submittedAt: submissions[index].submittedAt,
          evidenceFileUrl: submissions[index].evidenceFileUrl,
          studentNotes: submissions[index].studentNotes,
          status: status,
          lecturerFeedback: feedback,
          lecturerId: lecturerId,
          serverReceivedAt: submissions[index].serverReceivedAt,
        );
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
