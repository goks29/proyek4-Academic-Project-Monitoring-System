import 'package:hive/hive.dart';

part 'anggota_tubes_model.g.dart';

@HiveType(typeId: 1)
class AnggotaTubesModel extends HiveObject {
  @HiveField(0)
  late String projectId;

  @HiveField(1)
  late String profileId; // NIM

  @HiveField(2)
  late String role; // Ketua kalo ga anggota

  @HiveField(3)
  late DateTime joinedAt;

  AnggotaTubesModel({
    required this.projectId,
    required this.profileId,
    required this.role,
    required this.joinedAt,
  });
}