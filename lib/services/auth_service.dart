import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:academic_project_monitoring_system/models/user_model.dart';

import 'package:flutter/foundation.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _userBoxName = 'user_profile';

  // Login nder
  Future<UserModel?> login(String email, String password) async {
    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        final data = await _supabase
            .from('users')
            .select()
            .eq('id', res.user!.id)
            .single();

        final userProfile = UserModel.fromJson(data);
        var box = await Hive.openBox<UserModel>(_userBoxName);
        await box.put('current_user', userProfile);
        return userProfile;
      }
    } catch (e) {
      rethrow;
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