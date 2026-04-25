import 'package:hive/hive.dart';

part 'workspace_model.g.dart';

@HiveType(typeId: 0)
class WorkspaceModel extends HiveObject {
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
  late DateTime serverReceivedAt;

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
}