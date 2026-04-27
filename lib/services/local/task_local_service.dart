import 'package:hive/hive.dart';
import '../../models/task_allocation_model.dart';

// Local service for task_allocations table
/// Layanan untuk mengelola penyimpanan alokasi tugas di database lokal (Hive).
class TaskLocalService {
  final Box<TaskAllocationModel> _box;

  TaskLocalService(this._box);

  /// Mengambil daftar tugas berdasarkan ID fase dari storage lokal.
  List<TaskAllocationModel> getTasksByPhaseId(String phaseId) {
    return _box.values.where((task) => task.phaseId == phaseId).toList();
  }

  /// Menyimpan satu data tugas ke storage lokal.
  Future<void> saveTask(TaskAllocationModel task) async {
    await _box.put(task.id, task);
    print('Task ${task.id} saved to local storage.');
  }

  /// Menyimpan daftar tugas sekaligus ke storage lokal.
  Future<void> saveAllTasks(List<TaskAllocationModel> tasks) async {
    final Map<String, TaskAllocationModel> taskMap = {
      for (var t in tasks) t.id: t
    };
    await _box.putAll(taskMap);
    print('${tasks.length} tasks saved to local storage.');
  }

  Future<void> clearTasks() async {
    await _box.clear();
  }
}
