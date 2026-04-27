import 'package:hive/hive.dart';

/*
 * Tabel: users
 * Operasi & Aturan Bisnis:
 * - SELECT: Dapat diakses oleh seluruh pengguna yang terautentikasi karena informasi dasar profil (seperti nama) diperlukan untuk pencarian, identifikasi, dan kolaborasi di dalam sistem.
 * - UPDATE: Terbatas hanya untuk pemilik akun yang bersangkutan guna menjaga privasi, keamanan kredensial, dan integritas data individu.
 * - INSERT / DELETE: Tidak diizinkan melalui akses klien karena pembuatan dan penghapusan akun dikelola sepenuhnya oleh sistem autentikasi (Supabase Auth).
 */

part 'user_model.g.dart';

/// Model data yang merepresentasikan tabel 'users' di database.
@HiveType(typeId: 5)
class UserModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  /// Membuat instance UserModel dari format JSON Supabase.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  /// Mengonversi instance UserModel ke format JSON (hanya field yang bisa diubah).
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
    };
  }
}
