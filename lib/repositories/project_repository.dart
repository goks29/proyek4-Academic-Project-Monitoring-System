import '../services/local/project_local_service.dart';
import '../services/remote/project_service.dart';
import '../models/project_model.dart';

/// Repositori untuk mengelola data proyek.
/// Menangani sinkronisasi antara layanan remote (Supabase) dan layanan lokal (Hive).
class ProjectRepository {
  final ProjectService _remote;
  final ProjectLocalService _local;

  ProjectRepository(this._remote, this._local);

  /// Mengambil daftar semua proyek.
  /// Mencoba mengambil dari remote dan memperbarui data lokal. Jika gagal, mengembalikan data lokal.
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

  /// Mengambil data proyek berdasarkan kode akses (join code).
  Future<ProjectModel?> getProjectByJoinCode(String joinCode) async {
    final local = _local.getProjectByJoinCode(joinCode);
    if (local != null) return local;

    final remote = await _remote.getProjectByJoinCode(joinCode);
    if (remote != null) {
      await _local.saveProject(remote);
    }
    return remote;
  }

  /// Membuat proyek baru dan menyimpannya di remote serta lokal.
  Future<ProjectModel> createProject(ProjectModel project) async {
    final newProject = await _remote.createProject(project);
    await _local.saveProject(newProject);
    return newProject;
  }

  /// Memperbarui data proyek berdasarkan kode akses.
  Future<void> updateProject(String joinCode, Map<String, dynamic> data) async {
    await _remote.updateProject(joinCode, data);
    final updated = await _remote.getProjectByJoinCode(joinCode);
    if (updated != null) {
      await _local.saveProject(updated);
    }
  }

  /// Menutup proyek (mengubah status menjadi tidak aktif) berdasarkan kode akses.
  Future<void> closeProject(String joinCode) async {
    await _remote.closeProject(joinCode);
    final updated = await _remote.getProjectByJoinCode(joinCode);
    if (updated != null) {
      await _local.saveProject(updated);
    }
  }
}

