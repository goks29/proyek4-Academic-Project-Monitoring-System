import 'package:hive/hive.dart';
import '../../models/project_model.dart';

class ProjectLocalService {
  final Box<ProjectModel> _box;

  ProjectLocalService(this._box);

  List<ProjectModel> getAllProjects() {
    return _box.values.toList();
  }

  ProjectModel? getProjectByJoinCode(String joinCode) {
    return _box.get(joinCode);
  }

  Future<void> saveProject(ProjectModel project) async {
    await _box.put(project.joinCode, project);
  }

  Future<void> saveAllProjects(List<ProjectModel> projects) async {
    final Map<String, ProjectModel> projectMap = {
      for (var p in projects) p.joinCode: p
    };
    await _box.putAll(projectMap);
  }

  Future<void> clearProjects() async {
    await _box.clear();
  }
}
