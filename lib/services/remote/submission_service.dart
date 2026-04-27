import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/submission_model.dart';

// Service untuk operasi tabel submissions di Supabase
/// Layanan untuk berinteraksi dengan tabel 'submissions' di Supabase.
class SubmissionService {
  final SupabaseClient _client;

  SubmissionService(this._client);

  // Ambil semua submission berdasarkan phase_id
  /// Mengambil daftar submission mahasiswa berdasarkan ID fase.
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
  /// Mengirimkan data submission baru ke database cloud.
  Future<SubmissionModel> createSubmission(SubmissionModel submission) async {
    final response = await _client
        .from('submissions')
        .insert(submission.toJson())
        .select()
        .single();
    return SubmissionModel.fromJson(response);
  }

  // Update status dan feedback dari dosen
  /// Memperbarui status kelulusan dan catatan feedback dari dosen.
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
