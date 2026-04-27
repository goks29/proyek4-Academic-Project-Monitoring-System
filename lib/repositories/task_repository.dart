import '../services/local/task_local_service.dart';
import '../services/remote/task_service.dart';
import '../models/task_allocation_model.dart';

/// Repository untuk sinkronisasi pembagian tugas antar anggota tim.
class TaskRepository {
  final TaskService _remote;
  final TaskLocalService _local;

  TaskRepository(this._remote, this._local);

  /// Mengambil daftar tugas berdasarkan ID fase dengan sinkronisasi lokal.
  Future<List<TaskAllocationModel>> getTasks(String phaseId) async {
    final localData = _local.getTasksByPhaseId(phaseId);

    try {
      final remoteData = await _remote.getTasks(phaseId);
      await _local.saveAllTasks(remoteData);
      return remoteData;
    } catch (e) {
      print('Fetch remote tasks failed, using local data: $e');
      return localData;
    }
  }

  /// Membuat alokasi tugas baru dan menyimpannya di cloud serta lokal.
  Future<TaskAllocationModel> createTask(TaskAllocationModel task) async {
    final newTask = await _remote.createTask(task);
    await _local.saveTask(newTask);
    return newTask;
  }

  /// Memperbarui status persetujuan tugas dan sinkronisasi ke lokal.
  Future<void> approveTaskStatus(String taskId, String status) async {
    // Update di server
    await _remote.updateTaskApprovalStatus(taskId, status);
    
    // Update lokal untuk sinkronisasi UI instan
    final allLocal = _local.getTasksByPhaseId(''); // Cari di semua data lokal
    final index = allLocal.indexWhere((t) => t.id == taskId);
    
    if (index != -1) {
      final t = allLocal[index];
      final updated = TaskAllocationModel(
        id: t.id,
        phaseId: t.phaseId,
        studentId: t.studentId,
        taskDescription: t.taskDescription,
        isDone: t.isDone,
        status: status,
        lecturerFeedback: t.lecturerFeedback,
        clientCreatedAt: t.clientCreatedAt,
        serverReceivedAt: t.serverReceivedAt,
      );
      await _local.saveTask(updated);
    }
  }
}
