import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:academic_project_monitoring_system/models/task_allocation_model.dart';
import 'package:academic_project_monitoring_system/models/submission_model.dart';
import 'package:academic_project_monitoring_system/models/pending_submission_model.dart';
import 'package:academic_project_monitoring_system/services/remote/task_service.dart';
import 'package:academic_project_monitoring_system/services/remote/submission_service.dart';
import 'package:academic_project_monitoring_system/core/offline/offline_submission_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:academic_project_monitoring_system/models/sync_action_model.dart';

/// Controller untuk TaskDetailPage (di-scope per-route).
/// Menangani progress update dan upload bukti pengerjaan.
/// Mendukung offline submission via OfflineSubmissionManager.
class WorkspaceTaskController extends ChangeNotifier {
  final TaskService _taskService;
  final SubmissionService _submissionService;
  WorkspaceTaskController({
    TaskService? taskService,
    SubmissionService? submissionService
  })  : _taskService = taskService ?? TaskService(Supabase.instance.client),
        _submissionService = submissionService ?? SubmissionService(Supabase.instance.client);
  
  /// Offline submission manager — di-inject dari main.dart
  OfflineSubmissionManager? _offlineManager;

  TaskAllocationModel? _task;
  List<SubmissionModel> _submissions = [];
  List<PendingSubmissionModel> _pendingSubmissions = [];
  bool _isLoading = false;
  bool _isSavingProgress = false;
  bool _isSavingEvidence = false;
  String? _errorMessage;
  DateTime? _phaseDeadline;

  TaskAllocationModel? get task => _task;
  List<SubmissionModel> get submissions => _submissions;
  List<PendingSubmissionModel> get pendingSubmissions => _pendingSubmissions;
  bool get isLoading => _isLoading;
  bool get isSavingProgress => _isSavingProgress;
  bool get isSavingEvidence => _isSavingEvidence;
  /// Convenience getter: true jika ada operasi simpan apapun sedang berjalan.
  bool get isSaving => _isSavingProgress || _isSavingEvidence;
  DateTime? get phaseDeadline => _phaseDeadline;
  /// True jika deadline fase sudah terlewati.
  bool get isDeadlinePassed =>
      _phaseDeadline != null && DateTime.now().isAfter(_phaseDeadline!);
  String? get errorMessage => _errorMessage;

  /// Apakah ada submission yang menunggu sync.
  bool get hasPendingSync => _pendingSubmissions.isNotEmpty;

  /// Set offline submission manager (dipanggil saat init).
  void setOfflineManager(OfflineSubmissionManager manager) {
    _offlineManager = manager;
  }

  /// Set deadline fase untuk task ini.
  void setPhaseDeadline(DateTime? deadline) {
    _phaseDeadline = deadline;
    notifyListeners();
  }

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
      
      // Load pending submissions dari offline manager
      if (_offlineManager != null) {
        _pendingSubmissions = _offlineManager!.getPendingByTaskId(initialTask.id);
      }
    } catch (e) {
      try {
        final taskBox = await Hive.openBox<TaskAllocationModel>('tasks_box');
        final fetchedTask = taskBox.get(initialTask.id);
        if (fetchedTask != null) {
          _task = fetchedTask;
        }
        
        final submissionBox = await Hive.openBox<SubmissionModel>('submissions_box');
        _submissions = submissionBox.values.where((s) => s.taskId == initialTask.id).toList();
        _submissions.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
        
        if (_offlineManager != null) {
          _pendingSubmissions = _offlineManager!.getPendingByTaskId(initialTask.id);
        }
      } catch (e2) {
        _errorMessage = 'Gagal memuat data: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Update progress ────────────────────────────────────────────────────────

  Future<bool> updateProgress(String taskId, int progress) async {
    // Cek deadline sebelum proses
    if (isDeadlinePassed) {
      _errorMessage = 'Deadline fase telah terlewati. Anda tidak dapat mengupdate progress.';
      notifyListeners();
      return false;
    }

    _isSavingProgress = true;
    _errorMessage = null;
    notifyListeners();
    bool isNowDone = progress >= 100;
    try {
      // 1. Coba update online dulu
      await _taskService.updateTaskProgress(taskId, progress);
      if (_task != null && _task!.isDone != isNowDone) {
        await _taskService.updateTaskStatus(taskId, isNowDone);
      }

      // Update task di local cache ('tasks_box') agar konsisten
      final taskBox = await Hive.openBox<TaskAllocationModel>('tasks_box');
      final localTask = taskBox.get(taskId);
      if (localTask != null) {
        await taskBox.put(taskId, localTask.copyWith(progress: progress, isDone: isNowDone));
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
      // 2. Offline Fallback: Update lokal + Queue untuk sync
      try {
        final taskBox = await Hive.openBox<TaskAllocationModel>('tasks_box');
        final localTask = taskBox.get(taskId);
        if (localTask != null) {
          await taskBox.put(taskId, localTask.copyWith(progress: progress, isDone: isNowDone));
        }

        if (_task != null) {
          _task = _task!.copyWith(
            progress: progress,
            isDone: isNowDone,
          );
        }

        // Catat aksi update ke sync queue
        final syncActionBox = await Hive.openBox<SyncActionModel>('sync_actions_box');
        final actionId = const Uuid().v4();
        final action = SyncActionModel(
          id: actionId,
          table: 'task_allocations',
          method: 'update',
          payload: {
            'id': taskId,
            'progress': progress,
            'is_done': isNowDone,
          },
          createdAt: DateTime.now(),
        );
        await syncActionBox.put(actionId, action);

        notifyListeners();
        return true; // Berhasil menyimpan offline
      } catch (e2) {
        _errorMessage = 'Gagal mengupdate progress offline: ${e2.toString()}';
        notifyListeners();
        return false;
      }
    } finally {
      _isSavingProgress = false;
      notifyListeners();
    }
  }

  // ── Submit bukti ───────────────────────────────────────────────────────────

  /// Submit bukti pengerjaan — mendukung offline submission.
  /// 
  /// Jika OfflineSubmissionManager tersedia:
  /// - Online: submit langsung, fallback ke offline jika gagal
  /// - Offline: simpan lokal, queue untuk sync
  /// 
  /// Jika OfflineSubmissionManager tidak tersedia:
  /// - Gunakan alur lama (online only)
  Future<bool> submitEvidence({
    required String taskId,
    required String studentId,
    required XFile file,
    required String notes,
  }) async {
    // Cek deadline sebelum proses
    if (isDeadlinePassed) {
      _errorMessage = 'Deadline fase telah terlewati. Anda tidak dapat mengumpulkan bukti.';
      notifyListeners();
      return false;
    }

    _isSavingEvidence = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (_offlineManager != null) {
        // Alur baru: support offline
        final submission = await _offlineManager!.submitEvidence(
          taskId: taskId,
          studentId: studentId,
          file: file,
          notes: notes,
        );

        if (submission != null) {
          // Online submit berhasil
          _submissions = [submission, ..._submissions];
        } else {
          // Disimpan offline — refresh pending list
          _pendingSubmissions = _offlineManager!.getPendingByTaskId(taskId);
        }
      } else {
        // Alur lama: online only (backward compatibility)
        final submission = await _submissionService.uploadEvidenceAndSubmit(
          taskId: taskId,
          studentId: studentId,
          file: file,
          notes: notes,
        );
        _submissions = [submission, ..._submissions];
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengirim bukti: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isSavingEvidence = false;
      notifyListeners();
    }
  }

  /// Refresh pending submissions (dipanggil setelah sync selesai).
  void refreshPendingSubmissions(String taskId) {
    if (_offlineManager != null) {
      _pendingSubmissions = _offlineManager!.getPendingByTaskId(taskId);
      notifyListeners();
    }
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }
}
