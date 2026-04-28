import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/workspace_member_model.dart';

// Service untuk operasi tabel workspace_members di Supabase
class WorkspaceMemberService {
  final SupabaseClient _client;

  WorkspaceMemberService(this._client);

  // Ambil semua anggota dalam workspace tertentu
  Future<List<WorkspaceMemberModel>> getMembers(String workspaceId) async {
    final response = await _client
        .from('workspace_members')
        .select()
        .eq('workspace_id', workspaceId);
        
    return (response as List<dynamic>)
        .map((json) => WorkspaceMemberModel.fromJson(json))
        .toList();
  }

  // Tambah anggota baru ke workspace
  Future<WorkspaceMemberModel> addMember(WorkspaceMemberModel member) async {
    final response = await _client
        .from('workspace_members')
        .insert(member.toJson())
        .select()
        .single();
    return WorkspaceMemberModel.fromJson(response);
  }
}
