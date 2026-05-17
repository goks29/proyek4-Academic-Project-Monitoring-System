import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:academic_project_monitoring_system/models/progress_phase_model.dart';
import 'package:academic_project_monitoring_system/models/task_allocation_model.dart';
import 'package:academic_project_monitoring_system/models/workspace_model.dart';
import 'package:academic_project_monitoring_system/models/user_model.dart';
import 'package:academic_project_monitoring_system/services/remote/phase_service.dart';
import 'package:academic_project_monitoring_system/services/remote/task_service.dart';
import 'package:academic_project_monitoring_system/services/remote/workspace_service.dart';

/// Controller untuk WorkspaceDetailView (di-scope per-route).
/// Menangani semua operasi detail workspace: phase, task, members, topik.
class WorkspaceDetailController extends ChangeNotifier {
  final WorkspaceService _service = WorkspaceService(Supabase.instance.client);
  final PhaseService _phaseService = PhaseService(Supabase.instance.client);
  final TaskService _taskService = TaskService(Supabase.instance.client);
  final Uuid _uuid = const Uuid();

  List<ProgressPhaseModel> _allPhases = [];
  List<TaskAllocationModel> _allTask = [];
  List<UserModel> _workspaceMembers = [];
  WorkspaceModel? _currentWorkspace;
  bool _isCurrentUserLeader = false;
  bool _isLoading = false;
  String? _errorMessage;

  List<ProgressPhaseModel> get allPhases => _allPhases;
  List<TaskAllocationModel> get allTask => _allTask;
  List<UserModel> get workspaceMembers => _workspaceMembers;
  WorkspaceModel? get currentWorkspace => _currentWorkspace;
  bool get isCurrentUserLeader => _isCurrentUserLeader;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadWorkspaceData(String workspaceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _phaseService.getPhases(workspaceId),
        _service.fetchTasksByWorkspaces(workspaceId),
        _service.fetchWorkspacesMember(workspaceId),
        _service.checkIsLeader(workspaceId),
        _service.getWorkspaceById(workspaceId),
      ]);
      _allPhases = results[0] as List<ProgressPhaseModel>;
      _allTask = results[1] as List<TaskAllocationModel>;
      _workspaceMembers = results[2] as List<UserModel>;
      _isCurrentUserLeader = results[3] as bool;
      
      WorkspaceModel? fetchedWs = results[4] as WorkspaceModel?;
      if (fetchedWs == null) {
        // Fallback ke Hive
        final box = await Hive.openBox<WorkspaceModel>('workspaces');
        fetchedWs = box.get(workspaceId);
      }
      _currentWorkspace = fetchedWs;
    } catch (e) {
      _errorMessage = 'Gagal memuat data workspace: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Ketua: join project dosen ──────────────────────────────────────────────

  Future<bool> joinProjectAndLink(
      String joinCode, String workspaceId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      // Ambil UUID dan title dari tabel projects
      final response = await Supabase.instance.client
          .from('projects')
          .select('id, title')
          .eq('join_code', joinCode)
          .maybeSingle();

      if (response == null) {
        _errorMessage = 'Proyek tidak ditemukan dengan kode tersebut.';
        return false;
      }

      final projectId = response['id'] as String;
      final projectTitle = response['title'] as String;
      await _service.linkWorkspaceToProject(workspaceId, projectId);
      
      // Update state lokal seketika agar UI langsung responsif
      if (_currentWorkspace != null) {
        _currentWorkspace!.projectId = projectId;
        _currentWorkspace!.projectName = projectTitle;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _errorMessage =
          'Gagal menghubungkan workspace ke project: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Ketua: ajukan topik ────────────────────────────────────────────────────

  Future<void> submitTopic(
      String workspaceId, String topicName, String topicDescription) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _service.updateTopic(workspaceId, topicName,
          topicDescription: topicDescription);
    } catch (e) {
      _errorMessage = 'Gagal mengajukan topik: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // ── Ketua: buat phase ──────────────────────────────────────────────────────

  Future<void> createPhase(
      String workspaceId, String phaseName, int sortOrder) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final newPhase = ProgressPhaseModel(
        id: _uuid.v4(),
        workspaceId: workspaceId,
        phaseName: phaseName,
        sortOrder: sortOrder,
        status: 'pending',
        clientCreatedAt: DateTime.now(),
      );
      final saved = await _phaseService.createPhase(newPhase);
      _allPhases.add(saved);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal membuat phase: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // ── Ketua: alokasi task ────────────────────────────────────────────────────

  Future<void> createTaskAllocation(
      String phaseId, String studentId, String taskDescription) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final newTask = TaskAllocationModel(
        id: _uuid.v4(),
        phaseId: phaseId,
        studentId: studentId,
        taskDescription: taskDescription,
        isDone: false,
        status: 'pending',
        clientCreatedAt: DateTime.now(),
      );
      final saved = await _taskService.createTask(newTask);
      _allTask.add(saved);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal membuat task allocation: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // ── Ketua: batch create phase + tasks ─────────────────────────────────────

  Future<bool> createPhasesWithTasks(
    String workspaceId,
    List<
            ({
              String phaseName,
              int sortOrder,
              List<({String studentId, String taskDescription})> tasks
            })>
        phaseEntries,
  ) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      for (final entry in phaseEntries) {
        final newPhase = ProgressPhaseModel(
          id: _uuid.v4(),
          workspaceId: workspaceId,
          phaseName: entry.phaseName,
          sortOrder: entry.sortOrder,
          status: 'pending',
          clientCreatedAt: DateTime.now(),
        );
        final savedPhase = await _phaseService.createPhase(newPhase);
        _allPhases.add(savedPhase);

        if (entry.tasks.isNotEmpty) {
          final taskFutures = entry.tasks.map((t) async {
            final newTask = TaskAllocationModel(
              id: _uuid.v4(),
              phaseId: savedPhase.id,
              studentId: t.studentId,
              taskDescription: t.taskDescription,
              isDone: false,
              status: 'pending',
              clientCreatedAt: DateTime.now(),
            );
            final savedTask = await _taskService.createTask(newTask);
            _allTask.add(savedTask);
          });
          await Future.wait(taskFutures);
        }
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menyimpan phase & task: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<TaskAllocationModel> getTasksByPhase(String phaseId) =>
      _allTask.where((t) => t.phaseId == phaseId).toList();

  String getStudentName(String studentId) {
    try {
      return _workspaceMembers.firstWhere((m) => m.id == studentId).fullName;
    } catch (_) {
      return 'Belum Ada';
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
