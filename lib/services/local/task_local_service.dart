import 'package:hive/hive.dart';
import '../../models/task_allocation_model.dart';

// Local service for task_allocations table
class TaskLocalService {
  final Box<TaskAllocationModel> _box;

  TaskLocalService(this._box);

  List<TaskAllocationModel> getTasksByPhaseId(String phaseId) {
    return _box.values.where((task) => task.phaseId == phaseId).toList();
  }

  Future<void> saveTask(TaskAllocationModel task) async {
    await _box.put(task.id, task);
    print('Task ${task.id} saved to local storage.');
  }

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
