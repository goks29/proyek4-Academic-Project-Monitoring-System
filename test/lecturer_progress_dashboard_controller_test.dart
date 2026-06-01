import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:academic_project_monitoring_system/controllers/lecturer/progress_dashboard_controller.dart';
import 'package:academic_project_monitoring_system/models/workspace_model.dart';
import 'package:academic_project_monitoring_system/models/progress_phase_model.dart';
import 'package:academic_project_monitoring_system/models/task_allocation_model.dart';
import 'package:academic_project_monitoring_system/models/workspace_member_model.dart';
import 'package:academic_project_monitoring_system/repositories/workspace_repository.dart';
import 'package:academic_project_monitoring_system/repositories/workspace_member_repository.dart';
import 'package:academic_project_monitoring_system/repositories/phase_repository.dart';
import 'package:academic_project_monitoring_system/repositories/task_repository.dart';

// Mock //

class MockWorkspaceRepository extends Mock implements WorkspaceRepository {}
class MockMemberRepository extends Mock implements WorkspaceMemberRepository {}
class MockPhaseRepository extends Mock implements PhaseRepository {}
class MockTaskRepository extends Mock implements TaskRepository {}

// Data Dummy //

WorkspaceModel _fakeWorkspace({String id = 'ws-1'}) => WorkspaceModel(
      id: id,
      teamName: 'Team Alpha',
      joinCode: 'ABC123',
      progressionMode: 'strict',
      isCompleted: false,
      clientCreatedAt: DateTime(2024, 1, 1),
    );

ProgressPhaseModel _fakePhase({String id = 'phase-1'}) => ProgressPhaseModel(
      id: id,
      workspaceId: 'ws-1',
      phaseName: 'Phase 1',
      sortOrder: 1,
      status: 'pending',
      clientCreatedAt: DateTime(2024, 1, 1),
    );

TaskAllocationModel _fakeTask({
  String id = 'task-1',
  bool isDone = false,
  String studentId = 'student-1',
}) =>
    TaskAllocationModel(
      id: id,
      phaseId: 'phase-1',
      studentId: studentId,
      taskDescription: 'Task',
      isDone: isDone,
      status: isDone ? 'done' : 'pending',
      clientCreatedAt: DateTime(2024, 1, 1),
    );

WorkspaceMemberModel _fakeMember({String studentId = 'student-1'}) =>
    WorkspaceMemberModel(
      id: 'member-1',
      workspaceId: 'ws-1',
      studentId: studentId,
      isLeader: false,
    );

void main() {
  late ProgressDashboardController controller;
  late MockWorkspaceRepository mockWorkspaceRepo;
  late MockMemberRepository mockMemberRepo;
  late MockPhaseRepository mockPhaseRepo;
  late MockTaskRepository mockTaskRepo;

  setUp(() {
    mockWorkspaceRepo = MockWorkspaceRepository();
    mockMemberRepo = MockMemberRepository();
    mockPhaseRepo = MockPhaseRepository();
    mockTaskRepo = MockTaskRepository();

    controller = ProgressDashboardController(
      mockWorkspaceRepo,
      mockMemberRepo,
      mockPhaseRepo,
      mockTaskRepo,
    );
  });

  tearDown(() => controller.dispose());

  group('fetchGroupProgress', () {
    test('menghitung progress kelompok dari task yang selesai', () async {
      when(() => mockWorkspaceRepo.getWorkspacesByJoinCode('ABC123'))
          .thenAnswer((_) async => [_fakeWorkspace()]);
      when(() => mockPhaseRepo.getPhases('ws-1'))
          .thenAnswer((_) async => [_fakePhase()]);
      when(() => mockTaskRepo.getTasks('phase-1'))
          .thenAnswer((_) async => [
                _fakeTask(isDone: true),
                _fakeTask(id: 'task-2', isDone: false),
              ]);

      await controller.fetchGroupProgress('ABC123');

      expect(controller.groupProgressList.length, 1);
      expect(controller.groupProgressList.first.totalTasks, 2);
      expect(controller.groupProgressList.first.doneTasks, 1);
      expect(controller.groupProgressList.first.progressPercent, 50.0);
    });

    test('progress = 0 bila workspace tidak memiliki task', () async {
      when(() => mockWorkspaceRepo.getWorkspacesByJoinCode('ABC123'))
          .thenAnswer((_) async => [_fakeWorkspace()]);
      when(() => mockPhaseRepo.getPhases('ws-1'))
          .thenAnswer((_) async => [_fakePhase()]);
      when(() => mockTaskRepo.getTasks('phase-1'))
          .thenAnswer((_) async => []);

      await controller.fetchGroupProgress('ABC123');

      expect(controller.groupProgressList.first.progressPercent, 0);
    });

    test('menghitung progress untuk beberapa kelompok sekaligus', () async {
      when(() => mockWorkspaceRepo.getWorkspacesByJoinCode('ABC123'))
          .thenAnswer((_) async => [
                _fakeWorkspace(id: 'ws-1'),
                _fakeWorkspace(id: 'ws-2'),
              ]);
      when(() => mockPhaseRepo.getPhases('ws-1'))
          .thenAnswer((_) async => [_fakePhase()]);
      when(() => mockPhaseRepo.getPhases('ws-2'))
          .thenAnswer((_) async => []);
      when(() => mockTaskRepo.getTasks('phase-1'))
          .thenAnswer((_) async => [_fakeTask(isDone: true)]);

      await controller.fetchGroupProgress('ABC123');

      expect(controller.groupProgressList.length, 2);
    });

    test('menyimpan errorMessage bila fetch gagal', () async {
      when(() => mockWorkspaceRepo.getWorkspacesByJoinCode(any()))
          .thenThrow(Exception('Network error'));

      await controller.fetchGroupProgress('ABC123');

      expect(controller.errorMessage, contains('Network error'));
    });

    test('isLoading berubah true lalu false selama fetch', () async {
      final states = <bool>[];
      controller.addListener(() => states.add(controller.isLoading));
      when(() => mockWorkspaceRepo.getWorkspacesByJoinCode(any()))
          .thenAnswer((_) async => []);

      await controller.fetchGroupProgress('ABC123');

      expect(states.first, true);
      expect(states.last, false);
    });
  });

  group('fetchStudentProgress', () {
    test('menghitung progress per mahasiswa dari task yang selesai', () async {
      when(() => mockMemberRepo.getMembers('ws-1'))
          .thenAnswer((_) async => [_fakeMember(studentId: 'student-1')]);
      when(() => mockPhaseRepo.getPhases('ws-1'))
          .thenAnswer((_) async => [_fakePhase()]);
      when(() => mockTaskRepo.getTasks('phase-1'))
          .thenAnswer((_) async => [
                _fakeTask(isDone: true, studentId: 'student-1'),
                _fakeTask(id: 'task-2', isDone: false, studentId: 'student-1'),
              ]);

      await controller.fetchStudentProgress('ws-1');

      expect(controller.studentProgressList.length, 1);
      expect(controller.studentProgressList.first.totalTasks, 2);
      expect(controller.studentProgressList.first.doneTasks, 1);
      expect(controller.studentProgressList.first.progressPercent, 50.0);
    });

    test('progress = 0 bila mahasiswa tidak memiliki task', () async {
      when(() => mockMemberRepo.getMembers('ws-1'))
          .thenAnswer((_) async => [_fakeMember(studentId: 'student-1')]);
      when(() => mockPhaseRepo.getPhases('ws-1'))
          .thenAnswer((_) async => [_fakePhase()]);
      when(() => mockTaskRepo.getTasks('phase-1'))
          .thenAnswer((_) async => []);

      await controller.fetchStudentProgress('ws-1');

      expect(controller.studentProgressList.first.progressPercent, 0);
    });

    test('menyimpan errorMessage bila fetch gagal', () async {
      when(() => mockMemberRepo.getMembers(any()))
          .thenThrow(Exception('DB error'));

      await controller.fetchStudentProgress('ws-1');

      expect(controller.errorMessage, contains('DB error'));
    });
  });

  group('GroupProgressData', () {
    test('progressPercent = 100 bila semua task selesai', () {
      final data = GroupProgressData(
        workspaceId: 'ws-1',
        teamName: 'Team',
        totalTasks: 5,
        doneTasks: 5,
      );
      expect(data.progressPercent, 100.0);
    });

    test('progressPercent = 0 bila totalTasks = 0', () {
      final data = GroupProgressData(
        workspaceId: 'ws-1',
        teamName: 'Team',
        totalTasks: 0,
        doneTasks: 0,
      );
      expect(data.progressPercent, 0);
    });
  });

  group('StudentProgressData', () {
    test('progressPercent = 100 bila semua task mahasiswa selesai', () {
      final data = StudentProgressData(
        studentId: 'student-1',
        studentName: 'Alice',
        totalTasks: 3,
        doneTasks: 3,
      );
      expect(data.progressPercent, 100.0);
    });

    test('progressPercent = 0 bila totalTasks = 0', () {
      final data = StudentProgressData(
        studentId: 'student-1',
        studentName: 'Alice',
        totalTasks: 0,
        doneTasks: 0,
      );
      expect(data.progressPercent, 0);
    });
  });
}
