import '../services/local/workspace_member_local_service.dart';
import '../services/remote/workspace_member_service.dart';
import '../models/workspace_member_model.dart';

/// Repositori untuk mengelola keanggotaan kelompok.
class WorkspaceMemberRepository {
  final WorkspaceMemberService _remote;
  final WorkspaceMemberLocalService _local;

  WorkspaceMemberRepository(this._remote, this._local);

  /// Mengambil daftar anggota dalam satu kelompok tertentu.
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
}
