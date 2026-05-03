import '../services/local/workspace_local_service.dart';
import '../services/remote/workspace_service.dart';
import '../models/workspace_model.dart';

class WorkspaceRepository {
  final WorkspaceService _remote;
  final WorkspaceLocalService _local;

  WorkspaceRepository(this._remote, this._local);

  Future<List<WorkspaceModel>> getWorkspaces() async {
    final localData = _local.getAllWorkspaces();
    try {
      final remoteData = await _remote.getWorkspaces();
      await _local.saveAllWorkspaces(remoteData);
      return remoteData;
    } catch (e) {
      return localData;
    }
  }

  Future<List<WorkspaceModel>> getWorkspacesByJoinCode(String joinCode) async {
    try {
      return await _remote.getWorkspacesByJoinCode(joinCode);
    } catch (e) {
      return _local.getAllWorkspaces()
          .where((w) => w.joinCode == joinCode)
          .toList();
    }
  }

  Future<WorkspaceModel> createWorkspace(WorkspaceModel workspace) async {
    final created = await _remote.createWorkspace(workspace);
    await _local.saveWorkspace(created);
    return created;
  }

  Future<void> joinProject(String workspaceId, String joinCode) async {
    await _remote.joinProject(workspaceId, joinCode);
  }

  Future<void> updateWorkspace(String workspaceId, Map<String, dynamic> data) async {
    await _remote.updateWorkspace(workspaceId, data);
  }

  Future<void> updateTopicStatus(String workspaceId, String status, String? feedback) async {
    await _remote.updateTopicStatus(workspaceId, status, feedback);
  }
}
