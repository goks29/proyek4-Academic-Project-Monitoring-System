import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/submission_model.dart';

/// Service handling operations for the [submissions] table.
///
/// Row Level Security (RLS) Rules:
/// - SELECT: Accessible by team members and the project lecturer.
/// - INSERT: Allowed for all members of the respective team.
/// - UPDATE: Allowed for the student who uploaded the document or the project lecturer.
/// - DELETE: Not allowed through client access.
class SubmissionService {
  final SupabaseClient _client;

  SubmissionService(this._client);

  /// Fetches all submissions for a given [phaseId].
  Future<List<SubmissionModel>> getSubmissions(String phaseId) async {
    final response = await _client
        .from('submissions')
        .select()
        .eq('phase_id', phaseId);
        
    return (response as List<dynamic>)
        .map((json) => SubmissionModel.fromJson(json))
        .toList();
  }

  /// Creates a new submission for a phase.
  ///
  /// Allowed for any workspace member.
  Future<SubmissionModel> createSubmission(SubmissionModel submission) async {
    final response = await _client
        .from('submissions')
        .insert(submission.toJson())
        .select()
        .single();
    return SubmissionModel.fromJson(response);
  }

  /// Updates the status and feedback for a submission.
  ///
  /// Only allowed for the lecturer of the project.
  Future<void> updateStatus(String submissionId, String status, String feedback) async {
    await _client
        .from('submissions')
        .update({
          'status': status,
          'lecturer_feedback': feedback,
        })
        .eq('id', submissionId);
  }
}
