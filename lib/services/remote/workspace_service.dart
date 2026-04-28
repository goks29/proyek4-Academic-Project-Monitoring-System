import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/workspace_model.dart';

// Service untuk operasi tabel workspaces di Supabase
/// Layanan untuk berinteraksi dengan tabel 'workspaces' di Supabase.
class WorkspaceService {
  final SupabaseClient _client;

  WorkspaceService(this._client);

  // Ambil semua workspace yang tersedia
  /// Mengambil semua data workspace yang terdaftar di cloud.
  Future<List<WorkspaceModel>> getWorkspaces() async {
    final response = await _client.from('workspaces').select();
    return (response as List<dynamic>)
        .map((json) => WorkspaceModel.fromJson(json))
        .toList();
  }

  // Buat workspace baru (saat mahasiswa join project)
  /// Membuat workspace baru ketika mahasiswa bergabung ke proyek.
  Future<WorkspaceModel> createWorkspace(WorkspaceModel workspace) async {
    final response = await _client
        .from('workspaces')
        .insert(workspace.toJson())
        .select()
        .single();
    return WorkspaceModel.fromJson(response);
  }

  // Update topik proyek dalam workspace
  /// Memperbarui judul topik proyek di dalam sebuah workspace.
  Future<void> updateTopic(String workspaceId, String newTopic) async {
    await _client
        .from('workspaces')
        .update({'topic_name': newTopic})
        .eq('id', workspaceId);
  }
}