import 'package:hive/hive.dart';

part 'workspace_member_model.g.dart';

@HiveType(typeId: 1)
class WorkspaceMemberModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String workspaceId; // ID Project

  @HiveField(2)
  late String studentId; // NIM

  @HiveField(3)
  late bool isLeader;

  WorkspaceMemberModel({
    required this.id,
    required this.workspaceId,
    required this.studentId,
    required this.isLeader,
  });
}