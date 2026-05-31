import 'package:flutter/services.dart';

/// Service untuk mengakses monotonic clock Android (SystemClock.elapsedRealtime).
/// 
/// Monotonic clock tidak terpengaruh oleh perubahan jam HP oleh user,
/// sehingga bisa digunakan untuk menghitung elapsed time yang akurat
/// saat offline.
/// 
/// Hanya tersedia di Android. Di platform lain, fallback ke Stopwatch.
class MonotonicClockService {
  static const MethodChannel _channel = MethodChannel('com.academic/monotonic_clock');

  /// Mendapatkan elapsed realtime dalam milidetik sejak boot.
  /// Di Android: SystemClock.elapsedRealtime()
  /// Di platform lain: fallback ke DateTime.now() epoch (kurang akurat).
  Future<int> getElapsedRealtime() async {
    try {
      final int result = await _channel.invokeMethod('getElapsedRealtime');
      return result;
    } on PlatformException {
      // Fallback untuk platform non-Android (development/testing)
      return DateTime.now().millisecondsSinceEpoch;
    } on MissingPluginException {
      // Fallback jika platform channel belum terdaftar
      return DateTime.now().millisecondsSinceEpoch;
    }
  }
}
