import 'package:hive/hive.dart';
import '../../models/project_model.dart';

/// Layanan lokal untuk entitas Proyek menggunakan Hive.
/// Menangani penyimpanan data secara offline di perangkat.
class ProjectLocalService {
  final Box<ProjectModel> _box;

  ProjectLocalService(this._box);

  /// Mengambil semua daftar proyek yang tersimpan di penyimpanan lokal.
  List<ProjectModel> getAllProjects() {
    return _box.values.toList();
  }

  /// Mencari satu proyek berdasarkan kode akses (join code) di penyimpanan lokal.
  ProjectModel? getProjectByJoinCode(String joinCode) {
    return _box.get(joinCode);
  }

  /// Menyimpan atau memperbarui satu data proyek ke penyimpanan lokal.
  Future<void> saveProject(ProjectModel project) async {
    await _box.put(project.joinCode, project);
  }

  /// Menyimpan daftar proyek secara massal ke penyimpanan lokal.
  Future<void> saveAllProjects(List<ProjectModel> projects) async {
    final Map<String, ProjectModel> projectMap = {
      for (var p in projects) p.joinCode: p
    };
    await _box.putAll(projectMap);
  }

  /// Menghapus semua data proyek dari penyimpanan lokal.
  Future<void> clearProjects() async {
    await _box.clear();
  }
}

