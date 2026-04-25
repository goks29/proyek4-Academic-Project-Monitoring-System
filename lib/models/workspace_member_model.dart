/// Entity representation for the [workspace_members] table.
class WorkspaceMemberModel {
  final String id;
  final String workspaceId;
  final String studentId;
  final bool isLeader;

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
