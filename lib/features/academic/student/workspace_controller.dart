import 'package:academic_project_monitoring_system/models/progress_phase_model.dart';
import 'package:academic_project_monitoring_system/models/user_model.dart';
import 'package:academic_project_monitoring_system/services/remote/phase_service.dart';
import 'package:academic_project_monitoring_system/services/remote/project_service.dart';
import 'package:academic_project_monitoring_system/services/remote/task_service.dart';
import 'package:flutter/material.dart';
import 'package:academic_project_monitoring_system/models/workspace_model.dart';
import 'package:academic_project_monitoring_system/services/remote/workspace_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:academic_project_monitoring_system/models/task_allocation_model.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:academic_project_monitoring_system/models/workspace_member_model.dart';
import 'package:flutter/foundation.dart';


class WorkspaceController extends ChangeNotifier {
  final WorkspaceService _service = WorkspaceService(Supabase.instance.client);
  final PhaseService _phaseService = PhaseService(Supabase.instance.client);
  final TaskService _taskService = TaskService(Supabase.instance.client);
  final Uuid _uuid = const Uuid();

  List<WorkspaceModel> _myWorkspaces = [];
  List<ProgressPhaseModel> _allPhases = [];
  List<TaskAllocationModel> _allTask = [];
  List<UserModel> _workspaceMembers = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<WorkspaceModel> get myWorkspaces => _myWorkspaces;
  List<ProgressPhaseModel> get allPhases => _allPhases;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TaskAllocationModel> get allTask => _allTask;
  List<UserModel> get workspaceMembers => _workspaceMembers;

  /// Membuat WORKSPACES baru
  Future<void> createWorkspace({
    required String teamName,
    String? topic,
    String? description,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        _errorMessage = "User belum login.";
        return;
      }

      await _service.createWorkspace(
        teamName: teamName,
        creatorId: currentUser.id,
        topicName: topic,
        topicDescription: description,
      );
      await fetchMyWorkspaces(onlyLocal: true);
    } catch (e) {
      _errorMessage = "Gagal membuat kelompok: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  /// Mengambil Data WORKSPACES
  Future<void> fetchMyWorkspaces({bool onlyLocal = false}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      if (onlyLocal) {
        _myWorkspaces = await _service.getAllWorkspacesLocal();
      } else {
        _myWorkspaces = await _service.fetchWorkspacesFromCloud();
      }
    } catch (e) {
      _errorMessage = "Gagal memuat data kelompok.";
      _myWorkspaces = await _service.getAllWorkspacesLocal();
    } finally {
      _setLoading(false);
    }
  }

  /// Masuk WORKSPACES buatan KETUA via ID-WORKSPACES
  Future<bool> joinWorkspaceById(String workspaceId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        _errorMessage = "User belum login.";
        return false;
      }
      final workspace = await _service.getWorkspaceById(workspaceId);
      if (workspace == null) {
        _errorMessage = "Workspace tidak ditemukan. Pastikan ID sudah benar.";
        return false;
      }

      await _service.addMemberToWorkspace(
        workspaceId,
        currentUser.id,
        isLeader: false,
      );
      await fetchMyWorkspaces();
      return true;
    } catch (e) {
      _errorMessage = "Gagal bergabung ke workspace: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Masuk Project Tubes yang dibuat DOSEN
  Future<bool> joinProjectAndLink(String joinCode, String workspaceId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final ProjectService projectService =
          ProjectService(Supabase.instance.client);
      final project = await projectService.getProjectByJoinCode(joinCode);

      if (project == null) {
        _errorMessage = "Proyek tidak ditemukan dengan kode tersebut.";
        return false;
      }
      await _service.linkWorkspaceToProject(workspaceId, project.id);
      await fetchMyWorkspaces();
      return true;
    } catch (e) {
      _errorMessage = "Gagal menghubungkan workspace ke project: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Ketua MENGAJUKAN Topik ke Dosen
  Future<void> submitTopic(
    String workspaceId,
    String topicName,
    String topicDescription,
  ) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _service.updateTopic(
        workspaceId,
        topicName,
        topicDescription: topicDescription,
      );
      await fetchMyWorkspaces();
    } catch (e) {
      _errorMessage = "Gagal mengajukan topik: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  /// Mengajukan Fase ke Dosen
  Future<void> createPhase(
    String workspaceId,
    String phaseName,
    int sortOrder,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final newPhase = ProgressPhaseModel(
        id: _uuid.v4(),
        workspaceId: workspaceId,
        phaseName: phaseName,
        sortOrder: sortOrder,
        status: 'pending',
        isLocked: true,
        requireEvidence: true,
        clientCreatedAt: DateTime.now(),
      );

      final saved = await _phaseService.createPhase(newPhase);
      _allPhases.add(saved);
      notifyListeners();
    } catch (e) {
      _errorMessage = "Gagal membuat phase: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  /// Alokasi Tugas Oleh KETUA KELOMPOK
  Future<void> createTaskAllocation(
    String phaseId,
    String studentId,
    String taskDescription,
  ) async {
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
      _errorMessage = "Gagal membuat task allocation: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  /// Mengambil DETAIL dari WORKSPACES yang udah dibuat
  Future<void> loadWorkspaceData(String workspaceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load phases, tasks, dan members secara paralel
      final results = await Future.wait([
        _phaseService.getPhases(workspaceId),
        _service.fetchTasksByWorkspaces(workspaceId),
        _service.fetchWorkspacesMember(workspaceId),
      ]);

      _allPhases = results[0] as List<ProgressPhaseModel>;
      _allTask = results[1] as List<TaskAllocationModel>;
      _workspaceMembers = results[2] as List<UserModel>;
    } catch (e) {
      _errorMessage = "Gagal memuat data workspace: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //HELPERS

  /// Filter task berdasarkan phaseId.
  List<TaskAllocationModel> getTasksByPhase(String phaseId) {
    return _allTask.where((t) => t.phaseId == phaseId).toList();
  }

  /// Filter task berdasarkan workspaceId (via _allPhases).
  List<TaskAllocationModel> getTasksFromWorkspace(String workspaceId) {
    final phaseIds = _allPhases
        .where((phase) => phase.workspaceId == workspaceId)
        .map((phase) => phase.id)
        .toList();

    return _allTask
        .where((task) => phaseIds.contains(task.phaseId))
        .toList();
  }

  /// Dapatkan nama lengkap anggota berdasarkan studentId.
  String getStudentName(String studentId) {
    try {
      return _workspaceMembers
          .firstWhere((m) => m.id == studentId)
          .fullName;
    } catch (_) {
      return "Belum Ada";
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Bersihkan semua data lokal user saat ini.
  Future<void> clearLocalData() async {
    _myWorkspaces = [];
    _allPhases = [];
    _allTask = [];
    _workspaceMembers = [];
    _errorMessage = null;
    try {
      var wsBox = await Hive.openBox<WorkspaceModel>('workspaces');
      await wsBox.clear();
      var memberBox = await Hive.openBox<WorkspaceMemberModel>('workspace_members');
      await memberBox.clear();
    } catch (_) {}
    notifyListeners();
  }
}