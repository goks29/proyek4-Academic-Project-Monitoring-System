import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workspace_model.dart';

/// Service handling operations for the [workspaces] table.
///
/// Row Level Security (RLS) Rules:
/// - SELECT: Accessible by team members and the project lecturer.
/// - INSERT: Can be performed by any authenticated student when joining a project.
/// - UPDATE: Only allowed for the team leader or project lecturer.
/// - DELETE: Not allowed through client access.
class WorkspaceService {
  final SupabaseClient _client;

  WorkspaceService(this._client);

  /// Retrieves all workspaces visible to the current authenticated user.
  Future<List<WorkspaceModel>> getWorkspaces() async {
    final response = await _client.from('workspaces').select();
    return (response as List<dynamic>)
        .map((json) => WorkspaceModel.fromJson(json))
        .toList();
  }

  /// Creates a new workspace.
  ///
  /// Typically called when a student joins a project.
  Future<WorkspaceModel> createWorkspace(WorkspaceModel workspace) async {
    final response = await _client
        .from('workspaces')
        .insert(workspace.toJson())
        .select()
        .single();
    return WorkspaceModel.fromJson(response);
  }

  /// Updates the topic name for a specific [workspaceId].
  ///
  /// Only allowed for the workspace leader or the project lecturer.
  Future<void> updateTopic(String workspaceId, String newTopic) async {
    await _client
        .from('workspaces')
        .update({'topic_name': newTopic})
        .eq('id', workspaceId);
  }

  Future<bool> testConnection() async {
    try {
      await _client
          .from('mahasiswa')
          .select()
          .limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}