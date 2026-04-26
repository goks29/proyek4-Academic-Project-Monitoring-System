import 'package:hive/hive.dart';
import '../../models/project_model.dart';

// Local service for projects table
class ProjectLocalService {
  final Box<ProjectModel> _box;

  ProjectLocalService(this._box);

  List<ProjectModel> getAllProjects() {
    return _box.values.toList();
  }

  ProjectModel? getProjectById(String id) {
    return _box.get(id);
  }

  Future<void> saveProject(ProjectModel project) async {
    await _box.put(project.id, project);
    print('Project ${project.id} saved to local storage.');
  }

  Future<void> saveAllProjects(List<ProjectModel> projects) async {
    final Map<String, ProjectModel> projectMap = {
      for (var p in projects) p.id: p
    };
    await _box.putAll(projectMap);
    print('${projects.length} projects saved to local storage.');
  }

  Future<void> clearProjects() async {
    await _box.clear();
  }
}
