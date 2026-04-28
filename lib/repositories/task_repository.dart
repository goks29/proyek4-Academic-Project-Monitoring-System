import '../services/local/task_local_service.dart';
import '../services/remote/task_service.dart';
import '../models/task_allocation_model.dart';

// Repository untuk mengelola pembagian tugas
/// Repository untuk sinkronisasi pembagian tugas antar anggota tim.
class TaskRepository {
  final TaskService _remote;
  final TaskLocalService _local;

  TaskRepository(this._remote, this._local);

  // Ambil daftar tugas berdasarkan fase
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

  // Buat alokasi tugas baru (oleh ketua)
  /// Membuat alokasi tugas baru dan menyimpannya di cloud serta lokal.
  Future<TaskAllocationModel> createTask(TaskAllocationModel task) async {
    final newTask = await _remote.createTask(task);
    await _local.saveTask(newTask);
    return newTask;
  }
}
