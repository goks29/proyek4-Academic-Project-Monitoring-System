import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project_model.dart';

/// Service handling operations for the [projects] table.
///
/// Row Level Security (RLS) Rules:
/// - SELECT: Accessible by the project lecturer and students joined in a team within the project.
/// - INSERT / UPDATE / DELETE: Only allowed for the project lecturer.
class ProjectService {
  final SupabaseClient _client;

  ProjectService(this._client);

  /// Retrieves all projects visible to the current authenticated user.
  Future<List<ProjectModel>> getProjects() async {
    final response = await _client.from('projects').select();
    return (response as List<dynamic>)
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  }

  /// Creates a new project.
  ///
  /// Only allowed if the current user has the lecturer role.
  Future<ProjectModel> createProject(ProjectModel project) async {
    final response = await _client
        .from('projects')
        .insert(project.toJson())
        .select()
        .single();
    return ProjectModel.fromJson(response);
  }
}
