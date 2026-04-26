import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task_allocation_model.dart';

// Service untuk operasi tabel task_allocations di Supabase
class TaskService {
  final SupabaseClient _client;

  TaskService(this._client);

  // Ambil semua tugas berdasarkan phase_id
  Future<List<TaskAllocationModel>> getTasks(String phaseId) async {
    final response = await _client
        .from('task_allocations')
        .select()
        .eq('phase_id', phaseId);
        
    return (response as List<dynamic>)
        .map((json) => TaskAllocationModel.fromJson(json))
        .toList();
  }

  // Buat alokasi tugas baru
  Future<TaskAllocationModel> createTask(TaskAllocationModel task) async {
    final response = await _client
        .from('task_allocations')
        .insert(task.toJson())
        .select()
        .single();
    return TaskAllocationModel.fromJson(response);
  }

  // Update status penyelesaian tugas
  Future<void> updateTaskStatus(String taskId, bool isDone) async {
    await _client.from('task_allocations').update({'is_done': isDone}).eq('id', taskId);
  }
}
