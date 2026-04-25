import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_allocation_model.dart';

/// Service handling operations for the [task_allocations] table.
///
/// Row Level Security (RLS) Rules:
/// - SELECT: Accessible by team members and the project lecturer.
/// - INSERT: Only allowed for the team leader.
/// - UPDATE: Allowed for the team leader (task description), assigned student (completion status), and project lecturer (approval status).
/// - DELETE: Not allowed through client access.
class TaskService {
  final SupabaseClient _client;

  TaskService(this._client);

  /// Fetches all tasks allocated for a specific [phaseId].
  Future<List<TaskAllocationModel>> getTasks(String phaseId) async {
    final response = await _client
        .from('task_allocations')
        .select()
        .eq('phase_id', phaseId);
        
    return (response as List<dynamic>)
        .map((json) => TaskAllocationModel.fromJson(json))
        .toList();
  }

  /// Creates a new task allocation.
  ///
  /// Only allowed for the workspace leader.
  Future<TaskAllocationModel> createTask(TaskAllocationModel task) async {
    final response = await _client
        .from('task_allocations')
        .insert(task.toJson())
        .select()
        .single();
    return TaskAllocationModel.fromJson(response);
  }

  /// Updates the completion status ([isDone]) of a task.
  ///
  /// Allowed for the assigned student, the leader, or the lecturer.
  Future<void> markTaskAsDone(String taskId, bool isDone) async {
    await _client
        .from('task_allocations')
        .update({'is_done': isDone})
        .eq('id', taskId);
  }
}
