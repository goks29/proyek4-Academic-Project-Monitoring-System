import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:academic_project_monitoring_system/features/academic/student/controller/workspace_controller.dart';
import 'package:academic_project_monitoring_system/models/workspace_model.dart';
import 'package:academic_project_monitoring_system/models/task_allocation_model.dart';
import 'package:academic_project_monitoring_system/services/remote/workspace_service.dart';

// Mock //

class MockWorkspaceService extends Mock implements WorkspaceService {}

// Data Dummy //

WorkspaceModel _fakeWorkspace({String id = 'ws-1', String teamName = 'Team Alpha'}) =>
    WorkspaceModel(
      id: id,
      teamName: teamName,
      progressionMode: 'strict',
      isCompleted: false,
      clientCreatedAt: DateTime(2024, 1, 1),
    );

TaskAllocationModel _fakeTask({
  String id = 'task-1',
  String phaseId = 'phase-1',
  int progress = 50,
  bool isDone = false,
}) =>
    TaskAllocationModel(
      id: id,
      phaseId: phaseId,
      studentId: 'student-1',
      taskDescription: 'Test task',
      isDone: isDone,
      status: isDone ? 'done' : 'pending',
      clientCreatedAt: DateTime(2024, 1, 1),
      progress: progress,
    );


void main() {
  late WorkspaceController controller;
  late MockWorkspaceService mockService;

  setUp(() {
    mockService = MockWorkspaceService();
    controller = WorkspaceController(service: mockService);
  });

  tearDown(() => controller.dispose());

  group('fetchMyWorkspaces', () {
    test('jatuh ke cache lokal saat cloud gagal', () async {
      when(() => mockService.fetchWorkspacesFromCloud())
          .thenThrow(Exception('Network error'));
      when(() => mockService.getAllWorkspacesLocal())
          .thenAnswer((_) async => [_fakeWorkspace()]);

      await controller.fetchMyWorkspaces();

      expect(controller.myWorkspaces.length, 1);
      expect(controller.errorMessage, 'Gagal memuat data kelompok.');
    });

    test('memuat dari lokal saja bila onlyLocal = true', () async {
      when(() => mockService.getAllWorkspacesLocal())
          .thenAnswer((_) async => [_fakeWorkspace()]);
      when(() => mockService.fetchTasksByWorkspaces(any()))
          .thenAnswer((_) async => []);

      await controller.fetchMyWorkspaces(onlyLocal: true);

      verifyNever(() => mockService.fetchWorkspacesFromCloud());
      expect(controller.myWorkspaces.length, 1);
    });
  });

  group('calculateWorkspaceProgress', () {
    test('menghitung rata-rata progress dari semua task', () async {
      final tasks = [
        _fakeTask(progress: 40),
        _fakeTask(id: 'task-2', progress: 80),
      ];
      when(() => mockService.fetchTasksByWorkspaces('ws-1'))
          .thenAnswer((_) async => tasks);

      await controller.calculateWorkspaceProgress('ws-1');

      expect(controller.workspaceProgress['ws-1'], 60.0);
    });

    test('progress = 0.0 bila tidak ada task', () async {
      when(() => mockService.fetchTasksByWorkspaces('ws-empty'))
          .thenAnswer((_) async => []);

      await controller.calculateWorkspaceProgress('ws-empty');

      expect(controller.workspaceProgress['ws-empty'], 0.0);
    });

    test('notifyListeners dipanggil bila shouldNotify = true', () async {
      bool notified = false;
      controller.addListener(() => notified = true);
      when(() => mockService.fetchTasksByWorkspaces(any()))
          .thenAnswer((_) async => []);

      await controller.calculateWorkspaceProgress('ws-1');

      expect(notified, true);
    });

    test('tidak notifyListeners bila shouldNotify = false', () async {
      bool notified = false;
      controller.addListener(() => notified = true);
      when(() => mockService.fetchTasksByWorkspaces(any()))
          .thenAnswer((_) async => []);

      await controller.calculateWorkspaceProgress('ws-1', shouldNotify: false);

      expect(notified, false);
    });
  });

  group('createWorkspace', () {
    test('menyimpan errorMessage bila createWorkspace gagal', () async {
      when(() => mockService.createWorkspace(
            teamName: any(named: 'teamName'),
            creatorId: any(named: 'creatorId'),
            topicName: any(named: 'topicName'),
            topicDescription: any(named: 'topicDescription'),
          )).thenThrow(Exception('DB error'));

      await controller.createWorkspace(teamName: 'Fail Team');

      expect(controller.errorMessage, contains('Gagal membuat kelompok'));
    });
  });

  group('joinWorkspaceById', () {
    test('mengembalikan false bila terjadi exception', () async {
      when(() => mockService.getWorkspaceById(any()))
          .thenThrow(Exception('Network error'));

      final result = await controller.joinWorkspaceById('ws-1');

      expect(result, false);
      expect(controller.errorMessage, contains('Gagal bergabung'));
    });
  });
}