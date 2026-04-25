/// Entity representation for the [projects] table.
class ProjectModel {
  final String id;
  final String lecturerId;
  final String title;
  final String description;
  final String joinCode;
  final String? finalSubmissionInfo;

  ProjectModel({
    required this.id,
    required this.lecturerId,
    required this.title,
    required this.description,
    required this.joinCode,
    this.finalSubmissionInfo,
  });

  /// Maps JSON data from Supabase to the [ProjectModel] object.
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

  /// Converts the [ProjectModel] object to a JSON map for Supabase.
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
