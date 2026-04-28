import 'package:hive/hive.dart';

part 'progress_phase_model.g.dart';

// Representasi tabel progress_phases
@HiveType(typeId: 1)
class ProgressPhaseModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String workspaceId;

  @HiveField(2)
  final String phaseName;

  @HiveField(3)
  final int sortOrder;

  @HiveField(4)
  final String status;

  ProgressPhaseModel({
    required this.id,
    required this.workspaceId,
    required this.phaseName,
    required this.sortOrder,
    required this.status,
  });

  factory ProgressPhaseModel.fromJson(Map<String, dynamic> json) {
    return ProgressPhaseModel(
      id: json['id'] as String,
      workspaceId: json['workspace_id'] as String,
      phaseName: json['phase_name'] as String,
      sortOrder: json['sort_order'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workspace_id': workspaceId,
      'phase_name': phaseName,
      'sort_order': sortOrder,
      'client_created_at': DateTime.now().toIso8601String(),
    };
  }
}
