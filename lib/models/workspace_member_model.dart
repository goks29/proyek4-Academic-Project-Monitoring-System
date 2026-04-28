import 'package:hive/hive.dart';

part 'workspace_member_model.g.dart';

// Representasi tabel workspace_members
@HiveType(typeId: 7)
class WorkspaceMemberModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String workspaceId;

  @HiveField(2)
  final String studentId;

  @HiveField(3)
  final bool isLeader;

  WorkspaceMemberModel({
    required this.id,
    required this.workspaceId,
    required this.studentId,
    required this.isLeader,
  });

  factory WorkspaceMemberModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceMemberModel(
      id: json['id'] as String,
      workspaceId: json['workspace_id'] as String,
      studentId: json['student_id'] as String,
      isLeader: json['is_leader'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workspace_id': workspaceId,
      'student_id': studentId,
      'is_leader': isLeader,
    };
  }
}
