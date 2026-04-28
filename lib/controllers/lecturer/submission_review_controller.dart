import 'package:flutter/foundation.dart';
import '../../models/submission_model.dart';
import '../../repositories/submission_repository.dart';

class SubmissionReviewController extends ChangeNotifier {
  final SubmissionRepository _repository;

  List<SubmissionModel> submissions = [];
  bool isLoading = false;
  String? errorMessage;

  SubmissionReviewController(this._repository);

  Future<void> fetchSubmissions(String phaseId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      submissions = await _repository.getSubmissions(phaseId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reviewSubmission(String submissionId, String status, String feedback) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.reviewSubmission(submissionId, status, feedback);
      
      final index = submissions.indexWhere((s) => s.id == submissionId);
      if (index != -1) {
         submissions[index] = SubmissionModel(
            id: submissions[index].id,
            phaseId: submissions[index].phaseId,
            studentId: submissions[index].studentId,
            submittedAt: submissions[index].submittedAt,
            evidenceFileUrl: submissions[index].evidenceFileUrl,
            studentNotes: submissions[index].studentNotes,
            status: status,
            lecturerFeedback: feedback,
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
