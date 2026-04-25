import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// Service handling operations for the [users] table.
///
/// Row Level Security (RLS) Rules:
/// - SELECT: Accessible by all authenticated users.
/// - UPDATE: Only allowed for the account owner.
/// - INSERT / DELETE: Not allowed through client access.
class UserService {
  final SupabaseClient _client;

  UserService(this._client);

  /// Fetches the user profile for the given [userId].
  ///
  /// Throws an exception if the user does not have permission or if the profile is not found.
  Future<UserModel> getUserProfile(String userId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    return UserModel.fromJson(response);
  }

  /// Updates the full name of the user with [userId].
  ///
  /// Only allowed if the current user is the owner of the account.
  Future<void> updateProfile(String userId, String newName) async {
    await _client
        .from('users')
        .update({'full_name': newName})
        .eq('id', userId);
  }
}
