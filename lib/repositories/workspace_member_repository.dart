import '../services/local/workspace_member_local_service.dart';
import '../services/remote/workspace_member_service.dart';
import '../models/workspace_member_model.dart';

class WorkspaceMemberRepository {
  final WorkspaceMemberService _remote;
  final WorkspaceMemberLocalService _local;

  WorkspaceMemberRepository(this._remote, this._local);

  Future<List<WorkspaceMemberModel>> getMembers(String workspaceId) async {
    final localData = _local.getMembersByWorkspaceId(workspaceId);
    try {
      final remoteData = await _remote.getMembers(workspaceId);
      await _local.saveAllMembers(remoteData);
      return remoteData;
    } catch (e) {
      return localData;
    }
  }

  Future<WorkspaceMemberModel> addMember(WorkspaceMemberModel member) async {
    final created = await _remote.addMember(member);
    await _local.saveMember(created);
    return created;
  }
}
