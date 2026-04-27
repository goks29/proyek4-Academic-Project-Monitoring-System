import 'package:hive/hive.dart';
import '../../models/user_model.dart';

/// Local service for managing user data in Hive.
class UserLocalService {
  final Box<UserModel> _box;

  UserLocalService(this._box);

  /// Retrieves a user by their ID from local storage.
  UserModel? getUserById(String id) {
    return _box.get(id);
  }

  /// Saves a single user to local storage.
  Future<void> saveUser(UserModel user) async {
    await _box.put(user.id, user);
    print('User ${user.id} saved locally.');
  }

  /// Saves a list of users to local storage.
  Future<void> saveAllUsers(List<UserModel> users) async {
    final Map<String, UserModel> userMap = {
      for (var u in users) u.id: u
    };
    await _box.putAll(userMap);
    print('${users.length} users saved locally.');
  }
}
