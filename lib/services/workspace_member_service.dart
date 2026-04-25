import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workspace_member_model.dart';

/// Service handling operations for the [workspace_members] table.
///
/// Row Level Security (RLS) Rules:
/// - SELECT: Accessible by team members and the project lecturer.
/// - INSERT: Only allowed for the respective team leader.
/// - UPDATE / DELETE: Not allowed through client access.
class WorkspaceMemberService {
  final SupabaseClient _client;

  WorkspaceMemberService(this._client);

  /// Fetches all members of a specific [workspaceId].
  Future<List<WorkspaceMemberModel>> getMembers(String workspaceId) async {
    final response = await _client
        .from('workspace_members')
        .select()
        .eq('workspace_id', workspaceId);
        
    return (response as List<dynamic>)
        .map((json) => WorkspaceMemberModel.fromJson(json))
        .toList();
  }

  /// Adds a new member to a workspace.
  ///
  /// Only allowed if the current user is the leader of the workspace.
  Future<WorkspaceMemberModel> addMember(WorkspaceMemberModel member) async {
    final response = await _client
        .from('workspace_members')
        .insert(member.toJson())
        .select()
        .single();
    return WorkspaceMemberModel.fromJson(response);
  }
}
