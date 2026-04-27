import 'package:hive/hive.dart';

part 'workspace_model.g.dart';

/// Entity representation for the [WorkspaceModel] table.
@HiveType(typeId: 0)
class WorkspaceModel extends HiveObject{
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String projectId;

  @HiveField(2)
  late String teamName;

  @HiveField(3)
  String? topicName;

  @HiveField(4)
  String? topicDescription;

  @HiveField(5)
  late String progressionMode;

  @HiveField(6)
  late bool isCompleted;

  @HiveField(7)
  late DateTime clientCreatedAt;

  @HiveField(8)
  DateTime? serverReceivedAt;

  WorkspaceModel({
    required this.id,
    required this.projectId,
    required this.teamName,
    required this.topicName,
    required this.topicDescription,
    required this.progressionMode,
    required this.isCompleted,
    required this.clientCreatedAt,
    required this.serverReceivedAt
  });

  /// Membuat instance WorkspaceModel dari format JSON Supabase.
  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      teamName: json['team_name'] as String,
      topicName: json['topic_name'] as String? ?? '',
      topicDescription: json['topic_description'] as String? ?? '',
      progressionMode: json['progression_mode'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      clientCreatedAt: json['client_created_at'] as DateTime,
      serverReceivedAt: json['server_received_at'] as DateTime,
    );
  }

  /// Mengonversi instance WorkspaceModel ke format JSON untuk Supabase.
  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'team_name': teamName,
      'topic_name': topicName,
      'topic_description': topicDescription,
      'progression_mode': progressionMode,
      'is_completed': isCompleted,
      'client_created_at': clientCreatedAt.toIso8601String(),
    };
  }
}
