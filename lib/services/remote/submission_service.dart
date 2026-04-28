import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/submission_model.dart';

// Service untuk operasi tabel submissions di Supabase
class SubmissionService {
  final SupabaseClient _client;

  SubmissionService(this._client);

  // Ambil semua submission berdasarkan phase_id
  Future<List<SubmissionModel>> getSubmissions(String phaseId) async {
    final response = await _client
        .from('submissions')
        .select()
        .eq('phase_id', phaseId);
        
    return (response as List<dynamic>)
        .map((json) => SubmissionModel.fromJson(json))
        .toList();
  }

  // Kirim submission baru
  Future<SubmissionModel> createSubmission(SubmissionModel submission) async {
    final response = await _client
        .from('submissions')
        .insert(submission.toJson())
        .select()
        .single();
    return SubmissionModel.fromJson(response);
  }

  // Update status dan feedback dari dosen
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
