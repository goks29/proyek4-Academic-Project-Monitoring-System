import 'package:hive/hive.dart';

part 'session_token_model.g.dart';

/// Model untuk session token yang digunakan saat offline submission.
/// Token ini di-sign oleh server (HMAC-SHA256) dan berisi informasi
/// yang diperlukan untuk verifikasi submission offline.
@HiveType(typeId: 9)
class SessionTokenModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String deviceId;

  @HiveField(2)
  final DateTime serverTime;

  @HiveField(3)
  final int monotonicAtIssue; // elapsedRealtime() saat token dibuat

  @HiveField(4)
  final DateTime expiresAt;

  @HiveField(5)
  final String signature; // HMAC-SHA256 signature dari server

  SessionTokenModel({
    required this.userId,
    required this.deviceId,
    required this.serverTime,
    required this.monotonicAtIssue,
    required this.expiresAt,
    required this.signature,
  });

  /// Buat dari JSON response RPC issue_session_token().
  factory SessionTokenModel.fromJson(Map<String, dynamic> json) {
    return SessionTokenModel(
      userId: json['user_id'] as String,
      deviceId: json['device_id'] as String,
      serverTime: DateTime.parse(json['server_time'] as String),
      monotonicAtIssue: json['monotonic_at_issue'] is int
          ? json['monotonic_at_issue'] as int
          : int.parse(json['monotonic_at_issue'].toString()),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      signature: json['signature'] as String,
    );
  }

  /// Konversi ke Map untuk dikirim ke RPC verify_offline_submission().
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'device_id': deviceId,
      'server_time': serverTime.toIso8601String(),
      'monotonic_at_issue': monotonicAtIssue,
      'expires_at': expiresAt.toIso8601String(),
      'signature': signature,
    };
  }

  /// Cek apakah token masih berlaku berdasarkan waktu server
  /// (menggunakan estimasi dari monotonic clock).
  bool isExpired(DateTime estimatedCurrentTime) {
    return estimatedCurrentTime.isAfter(expiresAt);
  }

  /// Hitung estimasi waktu sekarang berdasarkan monotonic clock.
  /// elapsedNow = elapsedRealtime() saat ini.
  DateTime estimateCurrentTime(int elapsedNow) {
    final elapsedMs = elapsedNow - monotonicAtIssue;
    return serverTime.add(Duration(milliseconds: elapsedMs));
  }
}
