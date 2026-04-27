import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/project_model.dart';

// Service untuk operasi tabel projects di Supabase
/// Layanan untuk berinteraksi dengan tabel 'projects' di Supabase.
class ProjectService {
  final SupabaseClient _client;

  ProjectService(this._client);

  // Ambil semua proyek yang tersedia untuk user
  /// Mengambil semua data proyek yang tersedia di database cloud.
  Future<List<ProjectModel>> getProjects() async {
    final response = await _client.from('projects').select();
    return (response as List<dynamic>)
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  }

  // Buat proyek baru (hanya untuk dosen)
  /// Menyimpan data proyek baru ke tabel 'projects'.
  Future<ProjectModel> createProject(ProjectModel project) async {
    final response = await _client
        .from('projects')
        .insert(project.toJson())
        .select()
        .single();
    return ProjectModel.fromJson(response);
  }
}
