import 'package:hive/hive.dart';
import '../../models/progress_phase_model.dart';

// Local service for progress_phases table
class PhaseLocalService {
  final Box<ProgressPhaseModel> _box;

  PhaseLocalService(this._box);

  List<ProgressPhaseModel> getPhasesByWorkspaceId(String workspaceId) {
    final phases = _box.values.where((phase) => phase.workspaceId == workspaceId).toList();
    phases.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return phases;
  }

  Future<void> savePhase(ProgressPhaseModel phase) async {
    await _box.put(phase.id, phase);
    print('Phase ${phase.id} saved to local storage.');
  }

  Future<void> saveAllPhases(List<ProgressPhaseModel> phases) async {
    final Map<String, ProgressPhaseModel> phaseMap = {
      for (var p in phases) p.id: p
    };
    await _box.putAll(phaseMap);
    print('${phases.length} phases saved to local storage.');
  }

  Future<void> clearPhases() async {
    await _box.clear();
  }
}
