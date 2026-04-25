/// Entity representation for the [workspaces] table.
class WorkspaceModel {
  final String id;
  final String projectId;
  final String teamName;
  final String topicName;
  final String progressionMode;

  WorkspaceModel({
    required this.id,
    required this.projectId,
    required this.teamName,
    required this.topicName,
    required this.progressionMode,
  });

  /// Maps JSON data from Supabase to the [WorkspaceModel] object.
  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      teamName: json['team_name'] as String,
      topicName: json['topic_name'] as String? ?? '',
      progressionMode: json['progression_mode'] as String,
    );
  }

  /// Converts the [WorkspaceModel] object to a JSON map for Supabase.
  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'team_name': teamName,
      'topic_name': topicName,
      'progression_mode': progressionMode,
      'client_created_at': DateTime.now().toIso8601String(),
    };
  }
}
