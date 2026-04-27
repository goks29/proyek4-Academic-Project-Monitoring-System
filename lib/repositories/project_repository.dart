import '../services/local/project_local_service.dart';
import '../services/remote/project_service.dart';
import '../models/project_model.dart';

// Repository untuk mengelola data proyek
/// Repository yang mengelola sinkronisasi data proyek antara penyimpanan lokal dan server.
class ProjectRepository {
  final ProjectService _remote;
  final ProjectLocalService _local;

  ProjectRepository(this._remote, this._local);

  // Ambil daftar proyek: cek lokal dulu, lalu update dari remote
  /// Mengambil daftar proyek: memprioritaskan data lokal lalu memperbarui dari remote.
  Future<List<ProjectModel>> getProjects() async {
    // Ambil data dari penyimpanan lokal untuk respon cepat
    final localData = _local.getAllProjects();
    
    try {
      // Ambil data terbaru dari server
      final remoteData = await _remote.getProjects();
      // Simpan data terbaru ke lokal
      await _local.saveAllProjects(remoteData);
      return remoteData;
    } catch (e) {
      print('Fetch remote projects failed, using local data: $e');
      return localData;
    }
  }

  // Buat proyek baru
  /// Membuat proyek baru di server dan menyimpannya secara lokal.
  Future<ProjectModel> createProject(ProjectModel project) async {
    // Simpan ke remote (Supabase)
    final newProject = await _remote.createProject(project);
    // Simpan ke lokal (Hive)
    await _local.saveProject(newProject);
    return newProject;
  }
}
