import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/session_token_model.dart';
import 'monotonic_clock_service.dart';

/// Mengelola session token untuk offline submission.
/// 
/// Token di-request dari server (via Supabase RPC) saat online,
/// di-cache di secure storage, dan digunakan untuk menandatangani
/// submission saat offline.
class SessionTokenManager {
  final SupabaseClient _client;
  final MonotonicClockService _clock;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  SessionTokenModel? _cachedToken;
  String? _deviceId;

  SessionTokenManager(this._client, this._clock);

  /// Mendapatkan device ID yang unik untuk perangkat ini.
  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;
    
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      _deviceId = androidInfo.id; // Android ID
    } catch (e) {
      // Fallback: gunakan stored ID atau generate baru
      _deviceId = await _secureStorage.read(key: 'device_id');
      if (_deviceId == null) {
        _deviceId = DateTime.now().millisecondsSinceEpoch.toString();
        await _secureStorage.write(key: 'device_id', value: _deviceId!);
      }
    }
    return _deviceId!;
  }

  /// Request session token baru dari server.
  /// Harus dipanggil saat online.
  Future<SessionTokenModel?> requestToken() async {
    try {
      final deviceId = await getDeviceId();
      final monotonicNow = await _clock.getElapsedRealtime();

      final response = await _client.rpc('issue_session_token', params: {
        'p_device_id': deviceId,
        'p_monotonic_at_issue': monotonicNow,
      });

      if (response == null) {
        debugPrint('[SessionTokenManager] RPC returned null');
        return null;
      }

      final token = SessionTokenModel.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
      
      // Cache token
      _cachedToken = token;
      await _saveTokenToSecureStorage(token);
      
      debugPrint('[SessionTokenManager] Token issued, expires at: ${token.expiresAt}');
      return token;
    } catch (e) {
      debugPrint('[SessionTokenManager] Failed to request token: $e');
      return null;
    }
  }

  /// Mendapatkan token yang valid (dari cache atau request baru).
  /// Returns null jika offline dan tidak ada token cached.
  Future<SessionTokenModel?> getValidToken() async {
    // Coba dari memory cache
    if (_cachedToken != null) {
      final monotonicNow = await _clock.getElapsedRealtime();
      final estimatedNow = _cachedToken!.estimateCurrentTime(monotonicNow);
      
      if (!_cachedToken!.isExpired(estimatedNow)) {
        return _cachedToken;
      }
    }

    // Coba dari secure storage
    final stored = await _loadTokenFromSecureStorage();
    if (stored != null) {
      final monotonicNow = await _clock.getElapsedRealtime();
      final estimatedNow = stored.estimateCurrentTime(monotonicNow);
      
      if (!stored.isExpired(estimatedNow)) {
        _cachedToken = stored;
        return stored;
      }
    }

    // Token expired atau tidak ada, perlu request baru (hanya bisa saat online)
    return await requestToken();
  }

  /// Hitung estimasi waktu saat ini berdasarkan token dan monotonic clock.
  Future<DateTime?> estimateCurrentTime() async {
    final token = _cachedToken ?? await _loadTokenFromSecureStorage();
    if (token == null) return null;

    final monotonicNow = await _clock.getElapsedRealtime();
    return token.estimateCurrentTime(monotonicNow);
  }

  /// Hapus token yang tersimpan (dipanggil saat logout).
  Future<void> clearToken() async {
    _cachedToken = null;
    await _secureStorage.delete(key: 'session_token_userId');
    await _secureStorage.delete(key: 'session_token_deviceId');
    await _secureStorage.delete(key: 'session_token_serverTime');
    await _secureStorage.delete(key: 'session_token_monotonicAtIssue');
    await _secureStorage.delete(key: 'session_token_expiresAt');
    await _secureStorage.delete(key: 'session_token_signature');
  }

  // ── Private: Secure Storage Persistence ──────────────────────────────────

  Future<void> _saveTokenToSecureStorage(SessionTokenModel token) async {
    await _secureStorage.write(key: 'session_token_userId', value: token.userId);
    await _secureStorage.write(key: 'session_token_deviceId', value: token.deviceId);
    await _secureStorage.write(
        key: 'session_token_serverTime', value: token.serverTime.toIso8601String());
    await _secureStorage.write(
        key: 'session_token_monotonicAtIssue', value: token.monotonicAtIssue.toString());
    await _secureStorage.write(
        key: 'session_token_expiresAt', value: token.expiresAt.toIso8601String());
    await _secureStorage.write(key: 'session_token_signature', value: token.signature);
  }

  Future<SessionTokenModel?> _loadTokenFromSecureStorage() async {
    try {
      final userId = await _secureStorage.read(key: 'session_token_userId');
      final deviceId = await _secureStorage.read(key: 'session_token_deviceId');
      final serverTimeStr = await _secureStorage.read(key: 'session_token_serverTime');
      final monotonicStr = await _secureStorage.read(key: 'session_token_monotonicAtIssue');
      final expiresAtStr = await _secureStorage.read(key: 'session_token_expiresAt');
      final signature = await _secureStorage.read(key: 'session_token_signature');

      if (userId == null || deviceId == null || serverTimeStr == null || 
          monotonicStr == null || expiresAtStr == null || signature == null) {
        return null;
      }

      return SessionTokenModel(
        userId: userId,
        deviceId: deviceId,
        serverTime: DateTime.parse(serverTimeStr),
        monotonicAtIssue: int.parse(monotonicStr),
        expiresAt: DateTime.parse(expiresAtStr),
        signature: signature,
      );
    } catch (e) {
      debugPrint('[SessionTokenManager] Failed to load token: $e');
      return null;
    }
  }
}
