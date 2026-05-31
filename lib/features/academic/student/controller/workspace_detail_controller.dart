import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:academic_project_monitoring_system/models/progress_phase_model.dart';
import 'package:academic_project_monitoring_system/models/task_allocation_model.dart';
import 'package:academic_project_monitoring_system/models/workspace_model.dart';
import 'package:academic_project_monitoring_system/models/user_model.dart';
import 'package:academic_project_monitoring_system/models/workspace_member_model.dart';
import 'package:academic_project_monitoring_system/services/remote/phase_service.dart';
import 'package:academic_project_monitoring_system/services/remote/task_service.dart';
import 'package:academic_project_monitoring_system/services/remote/workspace_service.dart';

/// Controller untuk WorkspaceDetailView (di-scope per-route).
/// Menangani semua operasi detail workspace: phase, task, members, topik.
class WorkspaceDetailController extends ChangeNotifier {
  final WorkspaceService _service;
  final PhaseService _phaseService;
  final TaskService _taskService;
  final Uuid _uuid = const Uuid();

  WorkspaceDetailController({
    WorkspaceService? service,
    PhaseService? phaseService,
    TaskService? taskService,
  })  : _service = service ?? WorkspaceService(Supabase.instance.client),
        _phaseService = phaseService ?? PhaseService(Supabase.instance.client),
        _taskService = taskService ?? TaskService(Supabase.instance.client);

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
      // 1. Load Workspace
      WorkspaceModel? fetchedWs;
      try {
        fetchedWs = await _service.getWorkspaceById(workspaceId);
        if (fetchedWs != null) {
          final box = await Hive.openBox<WorkspaceModel>('workspaces');
          await box.put(workspaceId, fetchedWs);
        }
      } catch (_) {}

      if (fetchedWs == null) {
        final box = await Hive.openBox<WorkspaceModel>('workspaces');
        fetchedWs = box.get(workspaceId);
      }
      _currentWorkspace = fetchedWs;

      // 2. Load Phases
      List<ProgressPhaseModel> fetchedPhases = [];
      try {
        fetchedPhases = await _phaseService.getPhases(workspaceId);
        final phaseBox = await Hive.openBox<ProgressPhaseModel>('phases_box');
        for (var p in fetchedPhases) {
          await phaseBox.put(p.id, p);
        }
      } catch (_) {
        final phaseBox = await Hive.openBox<ProgressPhaseModel>('phases_box');
        fetchedPhases = phaseBox.values.where((p) => p.workspaceId == workspaceId).toList();
        fetchedPhases.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      }
      _allPhases = fetchedPhases;

      // 3. Load Tasks
      List<TaskAllocationModel> fetchedTasks = [];
      try {
        fetchedTasks = await _service.fetchTasksByWorkspaces(workspaceId);
        final taskBox = await Hive.openBox<TaskAllocationModel>('tasks_box');
        for (var t in fetchedTasks) {
          await taskBox.put(t.id, t);
        }
      } catch (_) {
        final taskBox = await Hive.openBox<TaskAllocationModel>('tasks_box');
        final phaseIds = _allPhases.map((p) => p.id).toSet();
        fetchedTasks = taskBox.values.where((t) => phaseIds.contains(t.phaseId)).toList();
      }
      _allTask = fetchedTasks;

      // 4. Load Members
      List<UserModel> fetchedMembers = [];
      try {
        fetchedMembers = await _service.fetchWorkspacesMember(workspaceId);
      } catch (_) {}

      if (fetchedMembers.isEmpty) {
        final memberBox = await Hive.openBox<WorkspaceMemberModel>('workspace_members_box');
        final userBox = await Hive.openBox<UserModel>('workspace_members_users');
        final memberEntries = memberBox.values.where((m) => m.workspaceId == workspaceId).toList();
        final studentIds = memberEntries.map((m) => m.studentId).toSet();
        fetchedMembers = userBox.values.where((u) => studentIds.contains(u.id)).toList();
      }
      _workspaceMembers = fetchedMembers;

      // 5. Load Leader status
      bool isLeader = false;
      try {
        isLeader = await _service.checkIsLeader(workspaceId);
      } catch (_) {}

      if (!isLeader) {
        final currentUser = Supabase.instance.client.auth.currentUser;
        if (currentUser != null) {
          final memberBox = await Hive.openBox<WorkspaceMemberModel>('workspace_members_box');
          final localMember = memberBox.values.firstWhere(
            (m) => m.workspaceId == workspaceId && m.studentId == currentUser.id,
            orElse: () => WorkspaceMemberModel(id: '', workspaceId: workspaceId, studentId: currentUser.id, isLeader: false),
          );
          isLeader = localMember.isLeader;
        }
      }
      _isCurrentUserLeader = isLeader;

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
      // Ambil title dari tabel projects via join_code
      final response = await Supabase.instance.client
          .from('projects')
          .select('join_code, title')
          .eq('join_code', joinCode)
          .maybeSingle();

      if (response == null) {
        _errorMessage = 'Proyek tidak ditemukan dengan kode tersebut.';
        return false;
      }

      final projectTitle = response['title'] as String;
      await _service.linkWorkspaceToProject(workspaceId, joinCode);
      
      // Update state lokal seketika agar UI langsung responsif
      if (_currentWorkspace != null) {
        _currentWorkspace!.joinCode = joinCode;
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
              DateTime? deadline,
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
          deadline: entry.deadline,
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
