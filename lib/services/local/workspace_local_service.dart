import 'package:hive/hive.dart';
import '../../models/workspace_model.dart';

/// Local service for managing workspace data in Hive.
class WorkspaceLocalService {
  final Box<WorkspaceModel> _box;

  WorkspaceLocalService(this._box);

  /// Retrieves all workspaces from local storage.
  List<WorkspaceModel> getAllWorkspaces() {
    return _box.values.toList();
  }

  /// Retrieves a specific workspace by its ID.
  WorkspaceModel? getWorkspaceById(String id) {
    return _box.get(id);
  }

  /// Saves a single workspace to local storage.
  Future<void> saveWorkspace(WorkspaceModel workspace) async {
    await _box.put(workspace.id, workspace);
    print('Workspace ${workspace.id} saved locally.');
  }

  /// Saves a list of workspaces to local storage.
  Future<void> saveAllWorkspaces(List<WorkspaceModel> workspaces) async {
    final Map<String, WorkspaceModel> workspaceMap = {
      for (var w in workspaces) w.id: w
    };
    await _box.putAll(workspaceMap);
    print('${workspaces.length} workspaces saved locally.');
  }
}
