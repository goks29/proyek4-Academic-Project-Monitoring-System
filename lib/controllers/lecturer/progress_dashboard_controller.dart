import 'package:flutter/foundation.dart';
import '../../models/task_allocation_model.dart';
import '../../models/workspace_model.dart';
import '../../repositories/workspace_repository.dart';
import '../../repositories/workspace_member_repository.dart';
import '../../repositories/phase_repository.dart';
import '../../repositories/task_repository.dart';

/// Data representasi progress pengerjaan kelompok.
class GroupProgressData {
  final String workspaceId;
  final String teamName;
  final int totalTasks;
  final int doneTasks;

  /// Menghitung persentase progress kelompok.
  double get progressPercent => totalTasks == 0 ? 0 : (doneTasks / totalTasks) * 100;

  GroupProgressData({
    required this.workspaceId,
    required this.teamName,
    required this.totalTasks,
    required this.doneTasks,
  });
}

/// Data representasi progress pengerjaan per mahasiswa.
class StudentProgressData {
  final String studentId;
  final String studentName;
  final int totalTasks;
  final int doneTasks;

  /// Menghitung persentase progress individu mahasiswa.
  double get progressPercent => totalTasks == 0 ? 0 : (doneTasks / totalTasks) * 100;

  StudentProgressData({
    required this.studentId,
    required this.studentName,
    required this.totalTasks,
    required this.doneTasks,
  });
}

/// Pengendali dashboard progress untuk dosen.
/// Menghitung akumulasi tugas dari berbagai fase dan anggota tim.
class ProgressDashboardController extends ChangeNotifier {
  final WorkspaceRepository _workspaceRepo;
  final WorkspaceMemberRepository _memberRepo;
  final PhaseRepository _phaseRepo;
  final TaskRepository _taskRepo;

  List<GroupProgressData> groupProgressList = [];
  List<StudentProgressData> studentProgressList = [];
  bool isLoading = false;
  String? errorMessage;

  ProgressDashboardController(
    this._workspaceRepo,
    this._memberRepo,
    this._phaseRepo,
    this._taskRepo,
  );

  /// Mengambil data progress untuk seluruh kelompok dalam satu kode proyek (join code).
  Future<void> fetchGroupProgress(String joinCode) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final workspaces = await _workspaceRepo.getWorkspacesByJoinCode(joinCode);
      groupProgressList = [];

      for (final workspace in workspaces) {
        final phases = await _phaseRepo.getPhases(workspace.id);
        int totalTasks = 0;
        int doneTasks = 0;

        for (final phase in phases) {
          final tasks = await _taskRepo.getTasks(phase.id);
          totalTasks += tasks.length;
          doneTasks += tasks.where((t) => t.isDone).length;
        }

        groupProgressList.add(GroupProgressData(
          workspaceId: workspace.id,
          teamName: workspace.teamName,
          totalTasks: totalTasks,
          doneTasks: doneTasks,
        ));
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Mengambil data progress per mahasiswa dalam satu kelompok (workspace).
  Future<void> fetchStudentProgress(String workspaceId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final members = await _memberRepo.getMembers(workspaceId);
      final phases = await _phaseRepo.getPhases(workspaceId);

      List<TaskAllocationModel> allTasks = [];
      for (final phase in phases) {
        allTasks.addAll(await _taskRepo.getTasks(phase.id));
      }

      studentProgressList = members.map((member) {
        final memberTasks = allTasks.where((t) => t.studentId == member.studentId).toList();
        return StudentProgressData(
          studentId: member.studentId,
          studentName: member.studentId, // Perlu diresolusi via UserRepository di layer UI jika perlu nama asli
          totalTasks: memberTasks.length,
          doneTasks: memberTasks.where((t) => t.isDone).length,
        );
      }).toList();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

