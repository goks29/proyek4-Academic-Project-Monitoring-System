import 'package:hive/hive.dart';

part 'workspace_model.g.dart';

/// Entity representation for the [WorkspaceModel] table.
@HiveType(typeId: 6)
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

  @HiveField(9)
  String? joinCode;

  @HiveField(10)
  String? status;

  @HiveField(11)
  String? lecturerFeedback;

  /// Nama project dari tabel `projects`. Tidak disimpan ke Hive (transient),
  /// diisi saat fetch dari cloud.
  String? projectName;

  WorkspaceModel({
    required this.id,
    this.projectId = '',
    this.joinCode,
    required this.teamName,
    this.topicName,
    this.topicDescription,
    required this.progressionMode,
    this.status,
    this.lecturerFeedback,
    required this.isCompleted,
    required this.clientCreatedAt,
    this.serverReceivedAt,
    this.projectName,
  });

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    // Ambil nama project dari join table jika tersedia
    final projectData = json['projects'] as Map<String, dynamic>?;
    return WorkspaceModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String? ?? '',
      joinCode: json['join_code'] as String?,
      teamName: json['team_name'] as String,
      topicName: json['topic_name'] as String?,
      topicDescription: json['topic_description'] as String?,
      progressionMode: json['progression_mode'] as String? ?? 'strict',
      status: json['status'] as String? ?? 'pending',
      lecturerFeedback: json['lecturer_feedback'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      clientCreatedAt: DateTime.parse(json['client_created_at'] as String),
      serverReceivedAt: json['server_received_at'] != null
          ? DateTime.parse(json['server_received_at'] as String)
          : null,
      projectName: projectData?['title'] as String?,
    );
  }

  /// Mengonversi instance WorkspaceModel ke format JSON untuk Supabase.
  /// [id] selalu disertakan agar UUID client di-insert ke server
  /// dan bisa digunakan oleh [linkWorkspaceToProject] dan HiveObject.save().
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'team_name': teamName,
      'progression_mode': progressionMode,
      'is_completed': isCompleted,
      'client_created_at': clientCreatedAt.toIso8601String(),
    };
    if (joinCode != null) data['join_code'] = joinCode;
    if (status != null) data['status'] = status;
    if (lecturerFeedback != null) data['lecturer_feedback'] = lecturerFeedback;
    // Hanya sertakan project_id jika sudah diisi (setelah join project dosen)
    if (projectId.isNotEmpty) data['project_id'] = projectId;
    if (topicName != null) data['topic_name'] = topicName;
    if (topicDescription != null) data['topic_description'] = topicDescription;
    return data;
  }
}
