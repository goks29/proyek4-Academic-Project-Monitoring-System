import 'package:hive/hive.dart';
import '../../models/project_model.dart';

// Local service for projects table
/// Layanan untuk mengelola penyimpanan data proyek di database lokal (Hive).
class ProjectLocalService {
  final Box<ProjectModel> _box;

  ProjectLocalService(this._box);

  /// Mengambil semua data proyek yang tersimpan di memori lokal.
  List<ProjectModel> getAllProjects() {
    return _box.values.toList();
  }

  /// Mencari data proyek berdasarkan ID unik secara lokal.
  ProjectModel? getProjectById(String id) {
    return _box.get(id);
  }

  /// Menyimpan satu data proyek ke dalam storage lokal.
  Future<void> saveProject(ProjectModel project) async {
    await _box.put(project.id, project);
    print('Project ${project.id} saved to local storage.');
  }

  /// Menyimpan daftar proyek sekaligus ke dalam storage lokal.
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
