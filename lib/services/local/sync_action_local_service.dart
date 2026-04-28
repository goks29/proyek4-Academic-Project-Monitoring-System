import 'package:hive/hive.dart';
import '../../models/sync_action_model.dart';

// Local service for offline sync actions
class SyncActionLocalService {
  final Box<SyncActionModel> _box;

  SyncActionLocalService(this._box);

  List<SyncActionModel> getPendingActions() {
    final actions = _box.values.toList();
    actions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return actions;
  }

  Future<void> addSyncAction(SyncActionModel action) async {
    await _box.put(action.id, action);
    print('Sync action ${action.method} on ${action.table} added to queue.');
  }

  Future<void> removeSyncAction(String id) async {
    await _box.delete(id);
    print('Sync action $id removed from queue.');
  }

  Future<void> clearQueue() async {
    await _box.clear();
  }
}
