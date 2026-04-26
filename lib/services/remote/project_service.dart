import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/project_model.dart';

// Service untuk operasi tabel projects di Supabase
class ProjectService {
  final SupabaseClient _client;

  ProjectService(this._client);

  // Ambil semua proyek yang tersedia untuk user
  Future<List<ProjectModel>> getProjects() async {
    final response = await _client.from('projects').select();
    return (response as List<dynamic>)
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  }

  // Buat proyek baru (hanya untuk dosen)
  Future<ProjectModel> createProject(ProjectModel project) async {
    final response = await _client
        .from('projects')
        .insert(project.toJson())
        .select()
        .single();
    return ProjectModel.fromJson(response);
  }
}
