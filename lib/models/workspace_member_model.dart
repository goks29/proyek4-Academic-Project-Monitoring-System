import 'package:hive/hive.dart';

part 'workspace_member_model.g.dart';
/// Entity representation for the [workspace_members] table.
@HiveType(typeId: 1)
class WorkspaceMemberModel extends HiveObject{
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

  /// Maps JSON data from Supabase to the [WorkspaceMemberModel] object.
  factory WorkspaceMemberModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceMemberModel(
      id: json['id'] as String,
      workspaceId: json['workspace_id'] as String,
      studentId: json['student_id'] as String,
      isLeader: json['is_leader'] as bool? ?? false,
    );
  }

  /// Converts the [WorkspaceMemberModel] object to a JSON map for Supabase.
  Map<String, dynamic> toJson() {
    return {
      'workspace_id': workspaceId,
      'student_id': studentId,
      'is_leader': isLeader,
    };
  }
}
