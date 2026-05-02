import '../services/local/phase_local_service.dart';
import '../services/remote/phase_service.dart';
import '../models/progress_phase_model.dart';

class PhaseRepository {
  final PhaseService _remote;
  final PhaseLocalService _local;

  PhaseRepository(this._remote, this._local);

  Future<List<ProgressPhaseModel>> getPhases(String workspaceId) async {
    final localData = _local.getPhasesByWorkspaceId(workspaceId);
    try {
      final remoteData = await _remote.getPhases(workspaceId);
      await _local.saveAllPhases(remoteData);
      return remoteData;
    } catch (e) {
      return localData;
    }
  }

  Future<ProgressPhaseModel> createPhase(ProgressPhaseModel phase) async {
    final created = await _remote.createPhase(phase);
    await _local.savePhase(created);
    return created;
  }

  Future<void> approvePhase(String phaseId, String status, String feedback) async {
    final updateData = <String, dynamic>{
      'status': status,
      'lecturer_feedback': feedback,
    };

    await _remote.updatePhaseStatus(phaseId, updateData);

    // Refresh local cache for the updated phase
    final allLocal = _local.getPhasesByWorkspaceId('');
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
        clientCreatedAt: p.clientCreatedAt,
        serverReceivedAt: p.serverReceivedAt,
      );
      await _local.savePhase(updated);
    }
  }
}
