import 'package:flutter/foundation.dart';
import '../../models/task_allocation_model.dart';
import '../../repositories/task_repository.dart';

class TaskApprovalController extends ChangeNotifier {
  final TaskRepository _repository;

  List<TaskAllocationModel> tasks = [];
  bool isLoading = false;
  String? errorMessage;

  TaskApprovalController(this._repository);

  Future<void> fetchTasks(String phaseId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      tasks = await _repository.getTasks(phaseId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveTask(String taskId, String status, {String? feedback}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.approveTaskStatus(taskId, status, feedback: feedback);

      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        tasks[index] = TaskAllocationModel(
          id: tasks[index].id,
          phaseId: tasks[index].phaseId,
          studentId: tasks[index].studentId,
          taskDescription: tasks[index].taskDescription,
          percentage: tasks[index].percentage,
          requireEvidence: tasks[index].requireEvidence,
          isDone: tasks[index].isDone,
          status: status,
          lecturerFeedback: feedback ?? tasks[index].lecturerFeedback,
          clientCreatedAt: tasks[index].clientCreatedAt,
          serverReceivedAt: tasks[index].serverReceivedAt,
        );
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRequireEvidence(String taskId, bool requireEvidence) async {
    try {
      await _repository.updateTask(taskId, {'require_evidence': requireEvidence});

      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        tasks[index] = TaskAllocationModel(
          id: tasks[index].id,
          phaseId: tasks[index].phaseId,
          studentId: tasks[index].studentId,
          taskDescription: tasks[index].taskDescription,
          percentage: tasks[index].percentage,
          requireEvidence: requireEvidence,
          isDone: tasks[index].isDone,
          status: tasks[index].status,
          lecturerFeedback: tasks[index].lecturerFeedback,
          clientCreatedAt: tasks[index].clientCreatedAt,
          serverReceivedAt: tasks[index].serverReceivedAt,
        );
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
