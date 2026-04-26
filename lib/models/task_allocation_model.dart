import 'package:hive/hive.dart';

part 'task_allocation_model.g.dart';

// Representasi tabel task_allocations
@HiveType(typeId: 2)
class TaskAllocationModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String phaseId;

  @HiveField(2)
  final String studentId;

  @HiveField(3)
  final String taskDescription;

  @HiveField(4)
  final bool isDone;

  @HiveField(5)
  final String status;

  TaskAllocationModel({
    required this.id,
    required this.phaseId,
    required this.studentId,
    required this.taskDescription,
    required this.isDone,
    required this.status,
  });

  factory TaskAllocationModel.fromJson(Map<String, dynamic> json) {
    return TaskAllocationModel(
      id: json['id'] as String,
      phaseId: json['phase_id'] as String,
      studentId: json['student_id'] as String,
      taskDescription: json['task_description'] as String,
      isDone: json['is_done'] as bool,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phase_id': phaseId,
      'student_id': studentId,
      'task_description': taskDescription,
      'client_created_at': DateTime.now().toIso8601String(),
    };
  }
}
