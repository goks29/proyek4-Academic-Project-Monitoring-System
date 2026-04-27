import 'package:flutter/foundation.dart';
import '../../models/progress_phase_model.dart';
import '../../repositories/phase_repository.dart';

/// Controller untuk menangani persetujuan fase kemajuan oleh dosen.
class PhaseApprovalController extends ChangeNotifier {
  final PhaseRepository _repository;

  List<ProgressPhaseModel> phases = [];
  bool isLoading = false;
  String? errorMessage;

  PhaseApprovalController(this._repository);

  /// Mengambil daftar fase berdasarkan ID workspace.
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

  /// Memperbarui status persetujuan fase dan memberikan feedback.
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
