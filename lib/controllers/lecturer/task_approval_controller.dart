import 'package:flutter/foundation.dart';
import '../../models/task_allocation_model.dart';
import '../../repositories/task_repository.dart';

/// Controller untuk memantau alokasi tugas mahasiswa oleh dosen.
class TaskApprovalController extends ChangeNotifier {
  final TaskRepository _repository;

  List<TaskAllocationModel> tasks = [];
  bool isLoading = false;
  String? errorMessage;

  TaskApprovalController(this._repository);

  /// Mengambil daftar alokasi tugas berdasarkan ID fase.
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
}
