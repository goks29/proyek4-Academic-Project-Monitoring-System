import 'package:hive/hive.dart';
import '../../models/submission_model.dart';

// Local service for submissions table
/// Layanan untuk mengelola penyimpanan data pengumpulan (submission) di database lokal (Hive).
class SubmissionLocalService {
  final Box<SubmissionModel> _box;

  SubmissionLocalService(this._box);

  /// Mengambil daftar submission berdasarkan ID fase dari storage lokal.
  List<SubmissionModel> getSubmissionsByPhaseId(String phaseId) {
    return _box.values.where((submission) => submission.phaseId == phaseId).toList();
  }

  /// Menyimpan satu data submission ke storage lokal.
  Future<void> saveSubmission(SubmissionModel submission) async {
    await _box.put(submission.id, submission);
    print('Submission ${submission.id} saved to local storage.');
  }

  /// Menyimpan daftar submission sekaligus ke storage lokal.
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
