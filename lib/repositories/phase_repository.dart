import '../services/local/phase_local_service.dart';
import '../services/remote/phase_service.dart';
import '../models/progress_phase_model.dart';

/// Repository untuk sinkronisasi data fase kemajuan proyek.
class PhaseRepository {
  final PhaseService _remote;
  final PhaseLocalService _local;

  PhaseRepository(this._remote, this._local);

  /// Mengambil daftar fase berdasarkan ID workspace dengan strategi offline-first.
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

  /// Memperbarui status persetujuan fase di server dan sinkronisasi ke lokal.
  Future<void> approvePhase(String phaseId, String status, String feedback) async {
    final Map<String, dynamic> updateData = {
      'status': status,
      'lecturer_feedback': feedback,
    };

    // Update di server
    await _remote.updatePhaseStatus(phaseId, updateData);
    
    // Update lokal agar UI berubah seketika tanpa refresh
    // Kita cari phase di seluruh data lokal (atau by workspaceId jika tersedia di context)
    final allLocal = _local.getPhasesByWorkspaceId(''); // Placeholder untuk ambil semua atau cari spesifik
    final index = allLocal.indexWhere((p) => p.id == phaseId);
    
    if (index != -1) {
      final p = allLocal[index];
      final updated = ProgressPhaseModel(
        id: p.id,
        workspaceId: p.workspaceId,
        phaseName: p.phaseName,
        sortOrder: p.sortOrder,
        status: status,
        lecturerFeedback: feedback,
        requireEvidence: p.requireEvidence,
        isLocked: p.isLocked,
        clientCreatedAt: p.clientCreatedAt,
        serverReceivedAt: p.serverReceivedAt,
      );
      await _local.savePhase(updated);
    }
  }
}
