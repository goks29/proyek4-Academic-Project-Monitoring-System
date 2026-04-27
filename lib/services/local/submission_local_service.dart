import 'package:hive/hive.dart';
import '../../models/submission_model.dart';

// Local service for submissions table
class SubmissionLocalService {
  final Box<SubmissionModel> _box;

  SubmissionLocalService(this._box);

  List<SubmissionModel> getSubmissionsByPhaseId(String phaseId) {
    return _box.values.where((submission) => submission.phaseId == phaseId).toList();
  }

  Future<void> saveSubmission(SubmissionModel submission) async {
    await _box.put(submission.id, submission);
    print('Submission ${submission.id} saved to local storage.');
  }

  Future<void> saveAllSubmissions(List<SubmissionModel> submissions) async {
    final Map<String, SubmissionModel> submissionMap = {
      for (var s in submissions) s.id: s
    };
    await _box.putAll(submissionMap);
    print('${submissions.length} submissions saved to local storage.');
  }

  Future<void> clearSubmissions() async {
    await _box.clear();
  }
}
