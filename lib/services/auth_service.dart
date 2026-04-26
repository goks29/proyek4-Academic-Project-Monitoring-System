import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:academic_project_monitoring_system/models/user_model.dart';

import 'package:flutter/foundation.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _userBoxName = 'user_profile';

  // Login nder
  // Future<UserModel?> login(String email, String password) async {
  //   final AuthResponse res = await _supabase.auth.signInWithPassword(
  //     email: email,
  //     password: password,
  //   );

  //   if (res.user != null) {
  //     final data = await _supabase
  //         .from('users')
  //         .select()
  //         .eq('id', res.user!.id)
  //         .single();

  //     final userProfile = UserModel.fromJson(data);
  //     var box = await Hive.openBox<UserModel>(_userBoxName);
  //     await box.put('current_user', userProfile);

  //     return userProfile;
  //   }
  //   return null;
  // }

  Future<UserModel?> login(String email, String password) async {
    debugPrint("🚀 [Service] Mencoba login untuk: $email");
    
    try {
      // Checkpoint 1: Sebelum Auth
      debugPrint("⏳ [Service] Menghubungi Supabase Auth...");
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint("✅ [Service] Respon Auth diterima. User ID: ${res.user?.id}");

      if (res.user != null) {
        // Checkpoint 2: Sebelum ambil data profil
        debugPrint("🔍 [Service] Mengambil profil dari tabel 'users'...");
        final data = await _supabase
            .from('users')
            .select()
            .eq('id', res.user!.id)
            .single();
        debugPrint("📊 [Service] Data profil berhasil ditarik.");

        final userProfile = UserModel.fromJson(data);

        // Checkpoint 3: Operasi Hive
        debugPrint("📦 [Service] Menyimpan profil ke Hive...");
        var box = await Hive.openBox<UserModel>(_userBoxName);
        await box.put('current_user', userProfile);
        debugPrint("✨ [Service] Selesai! Mengembalikan UserProfile.");

        return userProfile;
      }
    } catch (e) {
      // Kita tambahkan print di sini agar tahu socket error atau bukan
      debugPrint("❌ [Service] ERROR DI LEVEL SERVICE: $e");
      rethrow; // Tetap lempar error agar ditangkap controller
    }
    
    debugPrint("⚠️ [Service] User null, login gagal.");
    return null;
  }

  Future<UserModel?> getLocalProfile() async {
    var box = await Hive.openBox<UserModel>(_userBoxName);
    return box.get('current_user');
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    var box = await Hive.openBox<UserModel>(_userBoxName);
    await box.clear();
  }
}