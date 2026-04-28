import 'package:hive/hive.dart';

part 'workspace_model.g.dart';

// Representasi tabel workspaces
@HiveType(typeId: 6)
class WorkspaceModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String projectId;

  @HiveField(2)
  final String teamName;

  @HiveField(3)
  final String topicName;

  @HiveField(4)
  final String progressionMode;

  WorkspaceModel({
    required this.id,
    required this.projectId,
    required this.teamName,
    required this.topicName,
    required this.progressionMode,
  });

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      teamName: json['team_name'] as String,
      topicName: json['topic_name'] as String? ?? '',
      progressionMode: json['progression_mode'] as String,
    );
  }

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
