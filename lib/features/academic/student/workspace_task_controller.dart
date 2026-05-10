import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:academic_project_monitoring_system/models/task_allocation_model.dart';
import 'package:academic_project_monitoring_system/models/submission_model.dart';
import 'package:academic_project_monitoring_system/services/remote/task_service.dart';
import 'package:academic_project_monitoring_system/services/remote/submission_service.dart';

/// Controller untuk TaskDetailPage (di-scope per-route).
/// Menangani progress update dan upload bukti pengerjaan.
class WorkspaceTaskController extends ChangeNotifier {
  final TaskService _taskService = TaskService(Supabase.instance.client);
  final SubmissionService _submissionService =
      SubmissionService(Supabase.instance.client);

  TaskAllocationModel? _task;
  List<SubmissionModel> _submissions = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  TaskAllocationModel? get task => _task;
  List<SubmissionModel> get submissions => _submissions;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadTask(TaskAllocationModel initialTask) async {
    _task = initialTask;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _taskService.getTaskById(initialTask.id),
        _submissionService.getSubmissionsByTask(initialTask.id),
      ]);
      final fetchedTask = results[0] as TaskAllocationModel?;
      if (fetchedTask != null) {
        _task = fetchedTask;
      }
      _submissions = results[1] as List<SubmissionModel>;
    } catch (e) {
      _errorMessage = 'Gagal memuat data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Update progress ────────────────────────────────────────────────────────

  Future<bool> updateProgress(String taskId, int progress) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _taskService.updateTaskProgress(taskId, progress);
      
      bool isNowDone = progress >= 100;
      if (_task != null && _task!.isDone != isNowDone) {
        await _taskService.updateTaskStatus(taskId, isNowDone);
      }

      if (_task != null) {
        _task = _task!.copyWith(
          progress: progress,
          isDone: isNowDone,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate progress: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ── Submit bukti ───────────────────────────────────────────────────────────

  Future<bool> submitEvidence({
    required String taskId,
    required String phaseId,
    required String studentId,
    required XFile file,
    required String notes,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final submission = await _submissionService.uploadEvidenceAndSubmit(
        taskId: taskId,
        phaseId: phaseId,
        studentId: studentId,
        file: file,
        notes: notes,
      );
      _submissions = [submission, ..._submissions];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengirim bukti: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
