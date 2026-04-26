import '../services/local/phase_local_service.dart';
import '../services/remote/phase_service.dart';
import '../models/progress_phase_model.dart';

// Repository untuk mengelola fase progress
class PhaseRepository {
  final PhaseService _remote;
  final PhaseLocalService _local;

  PhaseRepository(this._remote, this._local);

  // Ambil daftar fase berdasarkan workspace
  Future<List<ProgressPhaseModel>> getPhases(String workspaceId) async {
    final localData = _local.getPhasesByWorkspaceId(workspaceId);

    try {
      final remoteData = await _remote.getPhases(workspaceId);
      await _local.saveAllPhases(remoteData);
      return remoteData;
    } catch (e) {
      print('Fetch remote phases failed, using local data: $e');
      return localData;
    }
  }

  // Update status fase (untuk dosen)
  Future<void> approvePhase(String phaseId, String status, String feedback) async {
    final Map<String, dynamic> updateData = {
      'status': status,
      'lecturer_feedback': feedback,
    };

    // Jalankan update di remote
    await _remote.updatePhaseStatus(phaseId, updateData);
    
    // Update data di lokal agar UI sinkron
    // Catatan: Di produksi, anda mungkin ingin fetch ulang atau update object lokal
  }
}
