import '../services/local/project_local_service.dart';
import '../services/remote/project_service.dart';
import '../models/project_model.dart';

class ProjectRepository {
  final ProjectService _remote;
  final ProjectLocalService _local;

  ProjectRepository(this._remote, this._local);

  Future<List<ProjectModel>> getProjects() async {
    final localData = _local.getAllProjects();
    try {
      final remoteData = await _remote.getProjects();
      await _local.saveAllProjects(remoteData);
      return remoteData;
    } catch (e) {
      return localData;
    }
  }

  Future<ProjectModel> getProjectByJoinCode(String joinCode) async {
    final local = _local.getProjectByJoinCode(joinCode);
    if (local != null) return local;

    final remote = await _remote.getProjectByJoinCode(joinCode);
    await _local.saveProject(remote);
    return remote;
  }

  Future<ProjectModel> createProject(ProjectModel project) async {
    final newProject = await _remote.createProject(project);
    await _local.saveProject(newProject);
    return newProject;
  }

  Future<void> updateProject(String joinCode, Map<String, dynamic> data) async {
    await _remote.updateProject(joinCode, data);
    final updated = await _remote.getProjectByJoinCode(joinCode);
    await _local.saveProject(updated);
  }

  Future<void> closeProject(String joinCode) async {
    await _remote.closeProject(joinCode);
    final updated = await _remote.getProjectByJoinCode(joinCode);
    await _local.saveProject(updated);
  }
}
