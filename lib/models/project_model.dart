import 'package:hive/hive.dart';

part 'project_model.g.dart';

// Representasi tabel projects
@HiveType(typeId: 0)
class ProjectModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String lecturerId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String joinCode;

  @HiveField(5)
  final String? finalSubmissionInfo;

  ProjectModel({
    required this.id,
    required this.lecturerId,
    required this.title,
    required this.description,
    required this.joinCode,
    this.finalSubmissionInfo,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      lecturerId: json['lecturer_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      joinCode: json['join_code'] as String,
      finalSubmissionInfo: json['final_submission_info'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lecturer_id': lecturerId,
      'title': title,
      'description': description,
      'join_code': joinCode,
      'final_submission_info': finalSubmissionInfo,
    };
  }
}
