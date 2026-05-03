import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task_allocation_model.dart';

class TaskService {
  final SupabaseClient _client;

  TaskService(this._client);

  Future<List<TaskAllocationModel>> getTasks(String phaseId) async {
    final response = await _client
        .from('task_allocations')
        .select()
        .eq('phase_id', phaseId);
    return (response as List<dynamic>)
        .map((json) => TaskAllocationModel.fromJson(json))
        .toList();
  }

  Future<TaskAllocationModel> createTask(TaskAllocationModel task) async {
    final response = await _client
        .from('task_allocations')
        .insert(task.toJson())
        .select()
        .single();
    return TaskAllocationModel.fromJson(response);
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    await _client.from('task_allocations').update(data).eq('id', taskId);
  }

  Future<void> updateTaskDoneStatus(String taskId, bool isDone) async {
    await _client
        .from('task_allocations')
        .update({'is_done': isDone})
        .eq('id', taskId);
  }

  Future<void> updateTaskApprovalStatus(String taskId, String status, {String? feedback}) async {
    final data = <String, dynamic>{'status': status};
    if (feedback != null) data['lecturer_feedback'] = feedback;
    await _client.from('task_allocations').update(data).eq('id', taskId);
  }

  Future<void> updateRequireEvidence(String taskId, bool requireEvidence) async {
    await _client
        .from('task_allocations')
        .update({'require_evidence': requireEvidence})
        .eq('id', taskId);
  }
}
