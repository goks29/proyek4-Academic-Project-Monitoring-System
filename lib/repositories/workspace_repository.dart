import '../services/local/workspace_local_service.dart';
import '../services/remote/workspace_service.dart';
import '../models/workspace_model.dart';

/// Repositori untuk mengelola data kelompok kerja (workspace).
class WorkspaceRepository {
  final WorkspaceService _remote;
  final WorkspaceLocalService _local;

  WorkspaceRepository(this._remote, this._local);

  /// Mengambil daftar seluruh kelompok kerja. Mendukung mode luring.
  Future<List<WorkspaceModel>> getWorkspaces() async {
    final localData = _local.getAllWorkspaces();
    try {
      final remoteData = await _remote.getWorkspaces();
      await _local.saveAllWorkspaces(remoteData);
      return remoteData;
    } catch (e) {
      return localData;
    }
  }
}
