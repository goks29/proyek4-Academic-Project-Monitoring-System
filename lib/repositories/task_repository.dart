import '../services/local/task_local_service.dart';
import '../services/remote/task_service.dart';
import '../models/task_allocation_model.dart';

class TaskRepository {
  final TaskService _remote;
  final TaskLocalService _local;

  TaskRepository(this._remote, this._local);

  Future<List<TaskAllocationModel>> getTasks(String phaseId) async {
    final localData = _local.getTasksByPhaseId(phaseId);
    try {
      final remoteData = await _remote.getTasks(phaseId);
      await _local.saveAllTasks(remoteData);
      return remoteData;
    } catch (e) {
      return localData;
    }
  }

  Future<TaskAllocationModel> createTask(TaskAllocationModel task) async {
    final newTask = await _remote.createTask(task);
    await _local.saveTask(newTask);
    return newTask;
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    await _remote.updateTask(taskId, data);
  }

  Future<void> approveTaskStatus(String taskId, String status, {String? feedback}) async {
    await _remote.updateTaskApprovalStatus(taskId, status, feedback: feedback);

    final allLocal = _local.getTasksByPhaseId('');
    final index = allLocal.indexWhere((t) => t.id == taskId);

    if (index != -1) {
      final t = allLocal[index];
      final updated = TaskAllocationModel(
        id: t.id,
        phaseId: t.phaseId,
        studentId: t.studentId,
        taskDescription: t.taskDescription,
        percentage: t.percentage,
        requireEvidence: t.requireEvidence,
        isDone: t.isDone,
        status: status,
        lecturerFeedback: feedback ?? t.lecturerFeedback,
        clientCreatedAt: t.clientCreatedAt,
        serverReceivedAt: t.serverReceivedAt,
      );
      await _local.saveTask(updated);
    }
  }

  Future<void> markTaskDone(String taskId, bool isDone) async {
    await _remote.updateTaskDoneStatus(taskId, isDone);
  }
}
