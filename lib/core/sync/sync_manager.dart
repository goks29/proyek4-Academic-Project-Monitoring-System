import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/sync_action_model.dart';
import '../../services/local/sync_action_local_service.dart';
import '../offline/offline_submission_manager.dart';

/// Kelas untuk mengelola sinkronisasi data lokal ke server.
/// 
/// Menangani dua jenis sync:
/// 1. Generic CRUD actions (insert/update/delete via SyncActionModel)
/// 2. Offline submissions (file upload + token verification)
class SyncManager {
  final SupabaseClient _supabaseClient;
  final SyncActionLocalService _localService;
  final OfflineSubmissionManager? _offlineSubmissionManager;
  bool _isSyncing = false;

  SyncManager(
    this._supabaseClient,
    this._localService, {
    OfflineSubmissionManager? offlineSubmissionManager,
  }) : _offlineSubmissionManager = offlineSubmissionManager;

  bool get isSyncing => _isSyncing;

  /// Memulai proses sinkronisasi semua data yang tertunda.
  Future<void> syncAll() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // 1. Sync generic CRUD actions
      await _syncCrudActions();

      // 2. Sync offline submissions
      if (_offlineSubmissionManager != null) {
        await _offlineSubmissionManager.syncAllPending();
      }
    } catch (error) {
      debugPrint('Sync error: $error');
    } finally {
      _isSyncing = false;
    }
  }

  /// Memulai proses sinkronisasi antrean data CRUD.
  Future<void> syncData() async {
    if (_isSyncing) return;
    
    _isSyncing = true;

    try {
      await _syncCrudActions();
    } catch (error) {
      debugPrint('Sync error: $error');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync generic CRUD actions.
  Future<void> _syncCrudActions() async {
    final pendingActions = _localService.getPendingActions();
    
    if (pendingActions.isEmpty) return;

    for (var action in pendingActions) {
      bool success = await _executeAction(action);
      
      if (success) {
        await _localService.removeSyncAction(action.id);
      } else {
        break;
      }
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
      debugPrint('Execute action error for ${action.table}: $error');
      return false;
    }
  }
}
