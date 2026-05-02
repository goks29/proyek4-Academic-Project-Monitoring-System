import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/project_model.dart';

class ProjectService {
  final SupabaseClient _client;

  ProjectService(this._client);

  Future<List<ProjectModel>> getProjects() async {
    final response = await _client.from('projects').select();
    return (response as List<dynamic>)
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  }

  Future<ProjectModel> getProjectByJoinCode(String joinCode) async {
    final response = await _client
        .from('projects')
        .select()
        .eq('join_code', joinCode)
        .single();
    return ProjectModel.fromJson(response);
  }

  Future<ProjectModel> createProject(ProjectModel project) async {
    final response = await _client
        .from('projects')
        .insert(project.toJson())
        .select()
        .single();
    return ProjectModel.fromJson(response);
  }

  Future<void> updateProject(String joinCode, Map<String, dynamic> data) async {
    await _client
        .from('projects')
        .update(data)
        .eq('join_code', joinCode);
  }

  Future<void> closeProject(String joinCode) async {
    await _client
        .from('projects')
        .update({'is_active': false})
        .eq('join_code', joinCode);
  }
}
