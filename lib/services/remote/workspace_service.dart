import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/workspace_model.dart';

class WorkspaceService {
  final SupabaseClient _client;

  WorkspaceService(this._client);

  Future<List<WorkspaceModel>> getWorkspaces() async {
    final response = await _client.from('workspaces').select();
    return (response as List<dynamic>)
        .map((json) => WorkspaceModel.fromJson(json))
        .toList();
  }

  Future<List<WorkspaceModel>> getWorkspacesByJoinCode(String joinCode) async {
    final response = await _client
        .from('workspaces')
        .select()
        .eq('join_code', joinCode);
    return (response as List<dynamic>)
        .map((json) => WorkspaceModel.fromJson(json))
        .toList();
  }

  Future<WorkspaceModel> createWorkspace(WorkspaceModel workspace) async {
    final response = await _client
        .from('workspaces')
        .insert(workspace.toJson())
        .select()
        .single();
    return WorkspaceModel.fromJson(response);
  }

  Future<void> joinProject(String workspaceId, String joinCode) async {
    await _client
        .from('workspaces')
        .update({'join_code': joinCode})
        .eq('id', workspaceId);
  }

  Future<void> updateWorkspace(String workspaceId, Map<String, dynamic> data) async {
    await _client
        .from('workspaces')
        .update(data)
        .eq('id', workspaceId);
  }

  Future<void> updateTopicStatus(String workspaceId, String status, String? feedback) async {
    await _client
        .from('workspaces')
        .update({
          'status': status,
          'lecturer_feedback': feedback,
        })
        .eq('id', workspaceId);
  }
}