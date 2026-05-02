import '../services/local/user_local_service.dart';
import '../services/remote/user_service.dart';
import '../models/user_model.dart';

class UserRepository {
  final UserService _remote;
  final UserLocalService _local;

  UserRepository(this._remote, this._local);

  Future<UserModel> getUser(String userId) async {
    final localUser = _local.getUserById(userId);
    if (localUser != null) return localUser;

    try {
      final remoteUser = await _remote.getUserProfile(userId);
      await _local.saveUser(remoteUser);
      return remoteUser;
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  Future<void> updateProfile(String userId, String newName) async {
    await _remote.updateProfile(userId, newName);
    final updated = await _remote.getUserProfile(userId);
    await _local.saveUser(updated);
  }
}
