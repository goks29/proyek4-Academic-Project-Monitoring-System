import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Monitor status konektivitas jaringan.
/// 
/// Memberikan notifikasi real-time saat perangkat online/offline,
/// dan otomatis men-trigger callback saat koneksi kembali (untuk sync).
class ConnectivityMonitor extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  /// Callback yang dipanggil saat koneksi kembali online.
  VoidCallback? onBackOnline;

  ConnectivityMonitor() {
    _init();
  }

  Future<void> _init() async {
    // Cek status awal
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    // Listen perubahan konektivitas
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      final wasOffline = !_isOnline;
      _updateStatus(result);
      
      // Trigger callback jika baru saja kembali online
      if (wasOffline && _isOnline) {
        debugPrint('[ConnectivityMonitor] Kembali online! Triggering sync...');
        onBackOnline?.call();
      }
    });
  }

  void _updateStatus(List<ConnectivityResult> result) {
    final newStatus = result.any((r) => r != ConnectivityResult.none);
    if (_isOnline != newStatus) {
      _isOnline = newStatus;
      debugPrint('[ConnectivityMonitor] Status: ${_isOnline ? "ONLINE" : "OFFLINE"}');
      notifyListeners();
    }
  }

  /// Cek konektivitas secara manual.
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
    return _isOnline;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
