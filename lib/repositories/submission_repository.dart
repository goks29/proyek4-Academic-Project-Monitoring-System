import '../services/local/submission_local_service.dart';
import '../services/remote/submission_service.dart';
import '../models/submission_model.dart';

// Repository untuk mengelola pengumpulan tugas (submission)
class SubmissionRepository {
  final SubmissionService _remote;
  final SubmissionLocalService _local;

  SubmissionRepository(this._remote, this._local);

  // Ambil daftar submission berdasarkan fase
  Future<List<SubmissionModel>> getSubmissions(String phaseId) async {
    final localData = _local.getSubmissionsByPhaseId(phaseId);

    try {
      final remoteData = await _remote.getSubmissions(phaseId);
      await _local.saveAllSubmissions(remoteData);
      return remoteData;
    } catch (e) {
      print('Fetch remote submissions failed, using local data: $e');
      return localData;
    }
  }

  // Review submission (oleh dosen)
  Future<void> reviewSubmission(String submissionId, String status, String feedback) async {
    // Update ke remote
    await _remote.updateStatus(submissionId, status, feedback);
    
    // Data lokal akan terupdate otomatis saat fetch berikutnya
    // atau anda bisa mengimplementasikan update lokal manual di sini
  }
}
