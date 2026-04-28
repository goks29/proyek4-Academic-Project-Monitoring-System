import 'package:hive/hive.dart';

part 'submission_model.g.dart';

// Representasi tabel submissions
@HiveType(typeId: 3)
class SubmissionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String phaseId;

  @HiveField(2)
  final String studentId;

  @HiveField(3)
  final String submittedAt;

  @HiveField(4)
  final String? evidenceFileUrl;

  @HiveField(5)
  final String? studentNotes;

  @HiveField(6)
  final String status;

  @HiveField(7)
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
