import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/progress_phase_model.dart';

/// Service handling operations for the [progress_phases] table.
///
/// Row Level Security (RLS) Rules:
/// - SELECT: Accessible by team members and the project lecturer.
/// - INSERT: Only allowed for the team leader.
/// - UPDATE: Allowed for the team leader (content changes) and project lecturer (status and feedback updates).
/// - DELETE: Not allowed through client access.
class PhaseService {
  final SupabaseClient _client;

  PhaseService(this._client);

  /// Fetches all progress phases for a given [workspaceId], ordered by [sort_order].
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

  /// Creates a new progress phase.
  ///
  /// Only allowed for the workspace leader.
  Future<ProgressPhaseModel> createPhase(ProgressPhaseModel phase) async {
    final response = await _client
        .from('progress_phases')
        .insert(phase.toJson())
        .select()
        .single();
    return ProgressPhaseModel.fromJson(response);
  }
}
