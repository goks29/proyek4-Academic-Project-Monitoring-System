/// Entity representation for the [progress_phases] table.
class ProgressPhaseModel {
  final String id;
  final String workspaceId;
  final String phaseName;
  final int sortOrder;
  final String status;

  ProgressPhaseModel({
    required this.id,
    required this.workspaceId,
    required this.phaseName,
    required this.sortOrder,
    required this.status,
  });

  /// Maps JSON data from Supabase to the [ProgressPhaseModel] object.
  factory ProgressPhaseModel.fromJson(Map<String, dynamic> json) {
    return ProgressPhaseModel(
      id: json['id'] as String,
      workspaceId: json['workspace_id'] as String,
      phaseName: json['phase_name'] as String,
      sortOrder: json['sort_order'] as int,
      status: json['status'] as String,
    );
  }

  /// Converts the [ProgressPhaseModel] object to a JSON map for Supabase.
  Map<String, dynamic> toJson() {
    return {
      'workspace_id': workspaceId,
      'phase_name': phaseName,
      'sort_order': sortOrder,
      'client_created_at': DateTime.now().toIso8601String(),
    };
  }
}
