import 'package:academic_project_monitoring_system/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:academic_project_monitoring_system/models/workspace_model.dart';
import 'package:academic_project_monitoring_system/services/remote/workspace_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:academic_project_monitoring_system/models/progress_phase_model.dart';
import 'package:academic_project_monitoring_system/models/task_allocation_model.dart';
class WorkspaceController extends ChangeNotifier {
  final WorkspaceService _service = WorkspaceService(Supabase.instance.client);

  List<WorkspaceModel> _myWorkspaces = [];
  List<ProgressPhaseModel> _allPhases = [];
  List<TaskAllocationModel> _allTask = [];
  List<UserModel> _workspaceMembers = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<WorkspaceModel> get myWorkspaces => _myWorkspaces;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TaskAllocationModel> get allTask => _allTask;
  List<UserModel> get workspaceMembers => _workspaceMembers;

  Future<void> createWorkspace({
    required String projectId,
    required String teamName,
    required String nim,
    String? topic,
    String? description
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _service.createWorkspace(
        projectId: projectId,
        teamName: teamName,
        creatorId: nim,
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

  Future<void> fetchMyWorkspaces({bool onlyLocal = false}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _myWorkspaces = await _service.getAllWorkspacesLocal();
      notifyListeners(); 
      if (!onlyLocal) {
        _myWorkspaces = await _service.fetchWorkspacesFromCloud();
      }
    } catch (e) {
      _errorMessage = "Gagal memuat data kelompok.";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadWorkspaceData(String workspaceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await Future.wait([
        _service.fetchTasksByWorkspaces(workspaceId),
        _service.fetchWorkspacesMember(workspaceId)
      ]);

      _allTask = result[0] as List<TaskAllocationModel>;
      _workspaceMembers = result[1] as List<UserModel>;
    }catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TaskAllocationModel> getTasksFromWorkspace (String workspaceId) {
    final List<String> phasesIdsInWorkspace = _allPhases
      .where((phase) => phase.workspaceId == workspaceId)
      .map((phase) => phase.id)
      .toList();

    return _allTask
      .where((task) => phasesIdsInWorkspace.contains(task.phaseId))
      .toList();
  }

  String getStudentName(String studentId) {
    try {
      return _workspaceMembers
        .firstWhere((m) => m.id == studentId)
        .fullName;
    } catch (_) {
      return "Belum Ada";
    }
  }

  List<TaskAllocationModel> getTasksByPhase(String phaseId) {
    return _allTask.where((t) => t.phaseId == phaseId).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}