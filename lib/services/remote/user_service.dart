import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';

// Service untuk operasi tabel users di Supabase
class UserService {
  final SupabaseClient _client;

  UserService(this._client);

  // Ambil profil user berdasarkan ID
  Future<UserModel> getUserProfile(String userId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    return UserModel.fromJson(response);
  }

  // Update nama lengkap user
  Future<void> updateProfile(String userId, String newName) async {
    await _client
        .from('users')
        .update({'full_name': newName})
        .eq('id', userId);
  }
}
