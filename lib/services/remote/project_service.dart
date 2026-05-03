import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/project_model.dart';

/// Layanan remote untuk entitas Proyek menggunakan Supabase.
class ProjectService {
  final SupabaseClient _client;

  ProjectService(this._client);

  /// Mengambil semua data proyek dari tabel 'projects'.
  Future<List<ProjectModel>> getProjects() async {
    final response = await _client.from('projects').select();
    return (response as List<dynamic>)
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  }

  /// Mengambil satu data proyek berdasarkan kode akses (join code).
  Future<ProjectModel> getProjectByJoinCode(String joinCode) async {
    final response = await _client
        .from('projects')
        .select()
        .eq('join_code', joinCode)
        .single();
    return ProjectModel.fromJson(response);
  }

  /// Menambahkan proyek baru ke dalam database.
  Future<ProjectModel> createProject(ProjectModel project) async {
    final response = await _client
        .from('projects')
        .insert(project.toJson())
        .select()
        .single();
    return ProjectModel.fromJson(response);
  }

  /// Memperbarui data proyek di database berdasarkan kode akses.
  Future<void> updateProject(String joinCode, Map<String, dynamic> data) async {
    await _client
        .from('projects')
        .update(data)
        .eq('join_code', joinCode);
  }

  /// Menonaktifkan proyek di database berdasarkan kode akses.
  Future<void> closeProject(String joinCode) async {
    await _client
        .from('projects')
        .update({'is_active': false})
        .eq('join_code', joinCode);
  }
}

