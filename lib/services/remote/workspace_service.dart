import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/workspace_model.dart';

// Service untuk operasi tabel workspaces di Supabase
class WorkspaceService {
  final SupabaseClient _client;

  WorkspaceService(this._client);

  // Ambil semua workspace yang tersedia
  Future<List<WorkspaceModel>> getWorkspaces() async {
    final response = await _client.from('workspaces').select();
    return (response as List<dynamic>)
        .map((json) => WorkspaceModel.fromJson(json))
        .toList();
  }

  // Buat workspace baru (saat mahasiswa join project)
  Future<WorkspaceModel> createWorkspace(WorkspaceModel workspace) async {
    final response = await _client
        .from('workspaces')
        .insert(workspace.toJson())
        .select()
        .single();
    return WorkspaceModel.fromJson(response);
  }

  // Update topik proyek dalam workspace
  Future<void> updateTopic(String workspaceId, String newTopic) async {
    await _client
        .from('workspaces')
        .update({'topic_name': newTopic})
        .eq('id', workspaceId);
  }
}