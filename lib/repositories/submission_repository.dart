import '../services/local/submission_local_service.dart';
import '../services/remote/submission_service.dart';
import '../models/submission_model.dart';

class SubmissionRepository {
  final SubmissionService _remote;
  final SubmissionLocalService _local;

  SubmissionRepository(this._remote, this._local);

  Future<List<SubmissionModel>> getSubmissionsByTaskId(String taskId) async {
    final localData = _local.getSubmissionsByTaskId(taskId);
    try {
      final remoteData = await _remote.getSubmissionsByTaskId(taskId);
      await _local.saveAllSubmissions(remoteData);
      return remoteData;
    } catch (e) {
      return localData;
    }
  }

  Future<SubmissionModel> createSubmission(SubmissionModel submission) async {
    final created = await _remote.createSubmission(submission);
    await _local.saveSubmission(created);
    return created;
  }

  Future<void> reviewSubmission(String submissionId, String status, String feedback, String lecturerId) async {
    await _remote.updateSubmissionReview(submissionId, status, feedback, lecturerId);

    final allLocal = _local.getSubmissionsByTaskId('');
    final index = allLocal.indexWhere((s) => s.id == submissionId);

    if (index != -1) {
      final s = allLocal[index];
      final updated = SubmissionModel(
        id: s.id,
        taskId: s.taskId,
        studentId: s.studentId,
        submittedAt: s.submittedAt,
        evidenceFileUrl: s.evidenceFileUrl,
        studentNotes: s.studentNotes,
        status: status,
        lecturerFeedback: feedback,
        lecturerId: lecturerId,
        serverReceivedAt: s.serverReceivedAt,
      );
      await _local.saveSubmission(updated);
    }
  }
}
