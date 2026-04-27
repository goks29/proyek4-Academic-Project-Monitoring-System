import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/progress_phase_model.dart';

// Service untuk operasi tabel progress_phases di Supabase
/// Layanan untuk berinteraksi dengan tabel 'progress_phases' di Supabase.
class PhaseService {
  final SupabaseClient _client;

  PhaseService(this._client);

  // Ambil semua fase berdasarkan workspace_id
  /// Mengambil daftar fase berdasarkan ID workspace, diurutkan sesuai sort_order.
  Future<List<ProgressPhaseModel>> getPhases(String workspaceId) async {
    final response = await _client
        .from('progress_phases')
        .select()
        .eq('workspace_id', workspaceId)
        .order('sort_order', ascending: true);
        
    return (response as List<dynamic>)
        .map((json) => ProgressPhaseModel.fromJson(json))
        .toList();
  }

  // Buat fase baru (hanya untuk ketua kelompok)
  /// Membuat entri fase baru di database cloud.
  Future<ProgressPhaseModel> createPhase(ProgressPhaseModel phase) async {
    final response = await _client
        .from('progress_phases')
        .insert(phase.toJson())
        .select()
        .single();
    return ProgressPhaseModel.fromJson(response);
  }

  // Update status atau feedback fase
  /// Memperbarui status atau catatan feedback pada fase tertentu.
  Future<void> updatePhaseStatus(String phaseId, Map<String, dynamic> data) async {
    await _client.from('progress_phases').update(data).eq('id', phaseId);
  }
}
