import 'package:hive/hive.dart';
import '../../models/submission_model.dart';

class SubmissionLocalService {
  final Box<SubmissionModel> _box;

  SubmissionLocalService(this._box);

  List<SubmissionModel> getSubmissionsByTaskId(String taskId) {
    return _box.values.where((s) => s.taskId == taskId).toList();
  }

  Future<void> saveSubmission(SubmissionModel submission) async {
    await _box.put(submission.id, submission);
  }

  Future<void> saveAllSubmissions(List<SubmissionModel> submissions) async {
    final Map<String, SubmissionModel> submissionMap = {
      for (var s in submissions) s.id: s
    };
    await _box.putAll(submissionMap);
  }

  Future<void> clearSubmissions() async {
    await _box.clear();
  }
}
