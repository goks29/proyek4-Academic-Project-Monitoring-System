/// Entity representation for the [submissions] table.
class SubmissionModel {
  final String id;
  final String phaseId;
  final String studentId;
  final String submittedAt;
  final String? evidenceFileUrl;
  final String? studentNotes;
  final String status;
  final String? lecturerFeedback;

  SubmissionModel({
    required this.id,
    required this.phaseId,
    required this.studentId,
    required this.submittedAt,
    this.evidenceFileUrl,
    this.studentNotes,
    required this.status,
    this.lecturerFeedback,
  });

  /// Maps JSON data from Supabase to the [SubmissionModel] object.
  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'] as String,
      phaseId: json['phase_id'] as String,
      studentId: json['student_id'] as String,
      submittedAt: json['submitted_at'] as String,
      evidenceFileUrl: json['evidence_file_url'] as String?,
      studentNotes: json['student_notes'] as String?,
      status: json['status'] as String,
      lecturerFeedback: json['lecturer_feedback'] as String?,
    );
  }

  /// Converts the [SubmissionModel] object to a JSON map for Supabase.
  Map<String, dynamic> toJson() {
    return {
      'phase_id': phaseId,
      'student_id': studentId,
      'submitted_at': submittedAt,
      'evidence_file_url': evidenceFileUrl,
      'student_notes': studentNotes,
    };
  }
}
