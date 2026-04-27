import '../services/local/user_local_service.dart';
import '../services/remote/user_service.dart';
import '../models/user_model.dart';

/// Repositori untuk mengelola data pengguna (mahasiswa/dosen).
class UserRepository {
  final UserService _remote;
  final UserLocalService _local;

  UserRepository(this._remote, this._local);

  /// Mengambil profil pengguna berdasarkan ID. Mencoba dari lokal dahulu.
  Future<UserModel> getUser(String userId) async {
    final localUser = _local.getUserById(userId);
    if (localUser != null) return localUser;

    try {
      final remoteUser = await _remote.getUserProfile(userId);
      await _local.saveUser(remoteUser);
      return remoteUser;
    } catch (e) {
      throw Exception('Gagal mengambil data user: $e');
    }
  }
}
