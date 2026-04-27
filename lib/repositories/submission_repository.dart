import '../services/local/submission_local_service.dart';
import '../services/remote/submission_service.dart';
import '../models/submission_model.dart';

/// Repository untuk mengelola data pengumpulan tugas mahasiswa.
class SubmissionRepository {
  final SubmissionService _remote;
  final SubmissionLocalService _local;

  SubmissionRepository(this._remote, this._local);

  /// Mengambil daftar submission berdasarkan ID fase.
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

  /// Memperbarui status review dan feedback dosen ke server serta sinkronisasi lokal.
  Future<void> reviewSubmission(String submissionId, String status, String feedback) async {
    // Update ke remote
    await _remote.updateStatus(submissionId, status, feedback);
    
    // Update lokal agar UI sinkron seketika
    final allLocal = _local.getSubmissionsByPhaseId(''); // Cari di semua data lokal
    final index = allLocal.indexWhere((s) => s.id == submissionId);
    
    if (index != -1) {
      final s = allLocal[index];
      final updated = SubmissionModel(
        id: s.id,
        phaseId: s.phaseId,
        studentId: s.studentId,
        submittedAt: s.submittedAt,
        evidenceFileUrl: s.evidenceFileUrl,
        studentNotes: s.studentNotes,
        status: status,
        lecturerFeedback: feedback,
        lecturerId: s.lecturerId,
        serverReceivedAt: s.serverReceivedAt,
      );
      await _local.saveSubmission(updated);
    }
  }
}
