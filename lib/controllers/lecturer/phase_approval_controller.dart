import 'package:flutter/foundation.dart';
import '../../models/progress_phase_model.dart';
import '../../repositories/phase_repository.dart';

class PhaseApprovalController extends ChangeNotifier {
  final PhaseRepository _repository;

  List<ProgressPhaseModel> phases = [];
  bool isLoading = false;
  String? errorMessage;

  PhaseApprovalController(this._repository);

  Future<void> fetchPhases(String workspaceId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      phases = await _repository.getPhases(workspaceId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approvePhase(String phaseId, String status, String feedback) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.approvePhase(phaseId, status, feedback);

      final index = phases.indexWhere((p) => p.id == phaseId);
      if (index != -1) {
        phases[index] = ProgressPhaseModel(
          id: phases[index].id,
          workspaceId: phases[index].workspaceId,
          phaseName: phases[index].phaseName,
          sortOrder: phases[index].sortOrder,
          status: status,
          lecturerFeedback: feedback,
          clientCreatedAt: phases[index].clientCreatedAt,
          serverReceivedAt: phases[index].serverReceivedAt,
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
