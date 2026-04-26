import 'package:hive/hive.dart';

part 'user_model.g.dart';
/// Entity representation for the [users] table.
@HiveType(typeId: 3)
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

  /// Maps JSON data from Supabase to the [UserModel] object.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  /// Converts the [UserModel] object to a JSON map for Supabase.
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
    };
  }
}
