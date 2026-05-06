import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task_allocation_model.dart';

/// Layanan untuk berinteraksi dengan tabel 'task_allocations' di Supabase.
class TaskService {
  final SupabaseClient _client;

  TaskService(this._client);

  /// Mengambil daftar alokasi tugas berdasarkan ID fase.
  Future<List<TaskAllocationModel>> getTasks(String phaseId) async {
    final response = await _client
        .from('task_allocations')
        .select()
        .eq('phase_id', phaseId);
    return (response as List<dynamic>)
        .map((json) => TaskAllocationModel.fromJson(json))
        .toList();
  }

  /// Mengambil satu task berdasarkan ID-nya.
  Future<TaskAllocationModel?> getTaskById(String taskId) async {
    final response = await _client
        .from('task_allocations')
        .select()
        .eq('id', taskId)
        .maybeSingle();
    if (response == null) return null;
    return TaskAllocationModel.fromJson(response);
  }

  /// Menyimpan alokasi tugas baru ke database cloud.
  Future<TaskAllocationModel> createTask(TaskAllocationModel task) async {
    final response = await _client
        .from('task_allocations')
        .insert(task.toJson())
        .select()
        .single();
    return TaskAllocationModel.fromJson(response);
  }

  /// Memperbarui persentase progress (0–100) pada tugas tertentu.
  Future<void> updateTaskProgress(String taskId, int progress) async {
    await _client
        .from('task_allocations')
        .update({'progress': progress})
        .eq('id', taskId);
  }

  /// Memperbarui status penyelesaian (is_done) pada tugas tertentu.
  Future<void> updateTaskStatus(String taskId, bool isDone) async {
    await _client
        .from('task_allocations')
        .update({'is_done': isDone})
        .eq('id', taskId);
  }
}
