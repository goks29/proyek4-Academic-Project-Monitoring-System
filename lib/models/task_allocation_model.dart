/// Entity representation for the [task_allocations] table.
class TaskAllocationModel {
  final String id;
  final String phaseId;
  final String studentId;
  final String taskDescription;
  final bool isDone;
  final String status;

  TaskAllocationModel({
    required this.id,
    required this.phaseId,
    required this.studentId,
    required this.taskDescription,
    required this.isDone,
    required this.status,
  });

  /// Maps JSON data from Supabase to the [TaskAllocationModel] object.
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

  /// Converts the [TaskAllocationModel] object to a JSON map for Supabase.
  Map<String, dynamic> toJson() {
    return {
      'phase_id': phaseId,
      'student_id': studentId,
      'task_description': taskDescription,
      'client_created_at': DateTime.now().toIso8601String(),
    };
  }
}
