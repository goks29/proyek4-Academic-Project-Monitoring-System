import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/submission_model.dart';

class SubmissionService {
  final SupabaseClient _client;

  SubmissionService(this._client);

  Future<List<SubmissionModel>> getSubmissionsByTaskId(String taskId) async {
    final response = await _client
        .from('submissions')
        .select()
        .eq('task_id', taskId);
    return (response as List<dynamic>)
        .map((json) => SubmissionModel.fromJson(json))
        .toList();
  }

  Future<SubmissionModel> createSubmission(SubmissionModel submission) async {
    final response = await _client
        .from('submissions')
        .insert(submission.toJson())
        .select()
        .single();
    return SubmissionModel.fromJson(response);
  }

  Future<void> updateSubmissionReview(String submissionId, String status, String feedback, String lecturerId) async {
    await _client
        .from('submissions')
        .update({
          'status': status,
          'lecturer_feedback': feedback,
          'lecturer_id': lecturerId,
        })
        .eq('id', submissionId);
  }
}
