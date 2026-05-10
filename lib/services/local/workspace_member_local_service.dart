import 'package:hive/hive.dart';
import '../../models/workspace_member_model.dart';

/// Local service for managing workspace member data in Hive.
class WorkspaceMemberLocalService {
  final Box<WorkspaceMemberModel> _box;

  WorkspaceMemberLocalService(this._box);

  /// Retrieves members belonging to a specific workspace ID.
  List<WorkspaceMemberModel> getMembersByWorkspaceId(String workspaceId) {
    return _box.values.where((member) => member.workspaceId == workspaceId).toList();
  }

  /// Saves a single workspace member to local storage.
  Future<void> saveMember(WorkspaceMemberModel member) async {
    await _box.put(member.id, member);
    print('Workspace member ${member.id} saved locally.');
  }

  /// Saves a list of workspace members to local storage.
  Future<void> saveAllMembers(List<WorkspaceMemberModel> members) async {
    final Map<String, WorkspaceMemberModel> memberMap = {
      for (var m in members) m.id: m
    };
    await _box.putAll(memberMap);
    print('${members.length} members saved locally.');
  }
}
