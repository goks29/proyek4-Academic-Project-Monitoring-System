import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/sync_action_model.dart';
import '../../services/local/sync_action_local_service.dart';

// Kelas untuk mengelola sinkronisasi data lokal ke server
class SyncManager {
  final SupabaseClient _supabaseClient;
  final SyncActionLocalService _localService;
  bool _isSyncing = false;

  SyncManager(this._supabaseClient, this._localService);

  // Memulai proses sinkronisasi antrean data
  Future<void> syncData() async {
    if (_isSyncing) return;
    
    _isSyncing = true;

    try {
      final pendingActions = _localService.getPendingActions();
      
      if (pendingActions.isEmpty) {
        _isSyncing = false;
        return;
      }

      for (var action in pendingActions) {
        bool success = await _executeAction(action);
        
        if (success) {
          await _localService.removeSyncAction(action.id);
        } else {
          break;
        }
      }
    } catch (error) {
      print('Sync error: $error');
    } finally {
      _isSyncing = false;
    }
  }

  // Mengeksekusi query ke Supabase berdasarkan metode yang disimpan
  Future<bool> _executeAction(SyncActionModel action) async {
    try {
      final table = _supabaseClient.from(action.table);
      final payload = Map<String, dynamic>.from(action.payload);

      switch (action.method.toLowerCase()) {
        case 'insert':
          await table.insert(payload);
          break;
        case 'update':
          if (!payload.containsKey('id')) return false;
          final id = payload['id'];
          payload.remove('id');
          await table.update(payload).eq('id', id);
          break;
        case 'delete':
          if (!payload.containsKey('id')) return false;
          await table.delete().eq('id', payload['id']);
          break;
        default:
          return false;
      }
      return true;
    } catch (error) {
      print('Execute action error for ${action.table}: $error');
      return false;
    }
  }
}
