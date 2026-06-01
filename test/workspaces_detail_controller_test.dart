import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:academic_project_monitoring_system/features/academic/student/controller/workspace_detail_controller.dart';
import 'package:academic_project_monitoring_system/models/workspace_model.dart';
import 'package:academic_project_monitoring_system/models/progress_phase_model.dart';
import 'package:academic_project_monitoring_system/models/task_allocation_model.dart';
import 'package:academic_project_monitoring_system/models/user_model.dart';
import 'package:academic_project_monitoring_system/services/remote/workspace_service.dart';
import 'package:academic_project_monitoring_system/services/remote/phase_service.dart';
import 'package:academic_project_monitoring_system/services/remote/task_service.dart';

// Mock //

class MockWorkspaceService extends Mock implements WorkspaceService {}
class MockPhaseService extends Mock implements PhaseService {}
class MockTaskService extends Mock implements TaskService {}
class FakeProgressPhaseModel extends Fake implements ProgressPhaseModel {}
class FakeTaskAllocationModel extends Fake implements TaskAllocationModel {}

// Data Dummy //

WorkspaceModel _fakeWorkspace({String id = 'ws-1'}) => WorkspaceModel(
      id: id,
      teamName: 'Team Alpha',
      progressionMode: 'strict',
      isCompleted: false,
      clientCreatedAt: DateTime(2024, 1, 1),
    );

ProgressPhaseModel _fakePhase({
  String id = 'phase-1',
  String workspaceId = 'ws-1',
  int sortOrder = 1,
}) =>
    ProgressPhaseModel(
      id: id,
      workspaceId: workspaceId,
      phaseName: 'Phase 1',
      sortOrder: sortOrder,
      status: 'pending',
      clientCreatedAt: DateTime(2024, 1, 1),
    );

TaskAllocationModel _fakeTask({
  String id = 'task-1',
  String phaseId = 'phase-1',
  bool isDone = false,
}) =>
    TaskAllocationModel(
      id: id,
      phaseId: phaseId,
      studentId: 'student-1',
      taskDescription: 'Do something',
      isDone: isDone,
      status: isDone ? 'done' : 'pending',
      clientCreatedAt: DateTime(2024, 1, 1),
    );

UserModel _fakeUser({
  String id = 'student-1',
  String fullName = 'Alice',
}) =>
    UserModel(
      id: id,
      fullName: fullName,
      email: 'alice@example.com',
      role: 'student',
      createdAt: DateTime(2024, 1, 1),
    );

void main() {
  late WorkspaceDetailController controller;
  late MockWorkspaceService mockWorkspaceService;
  late MockPhaseService mockPhaseService;
  late MockTaskService mockTaskService;

  setUpAll(() {
    registerFallbackValue(FakeProgressPhaseModel());
    registerFallbackValue(FakeTaskAllocationModel());
    final tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
  });

  setUp(() {
    mockWorkspaceService = MockWorkspaceService();
    mockPhaseService = MockPhaseService();
    mockTaskService = MockTaskService();

    controller = WorkspaceDetailController(
      service: mockWorkspaceService,
      phaseService: mockPhaseService,
      taskService: mockTaskService,
    );
  });

  setUp(() {
    addTearDown(() => controller.dispose());
  });

  group('joinProjectAndLink', () {
    test('mengembalikan false bila linkWorkspaceToProject gagal', () async {
      when(() => mockWorkspaceService.linkWorkspaceToProject(any(), any()))
          .thenThrow(Exception('not found'));

      final result = await controller.joinProjectAndLink('INVALID', 'ws-1');

      expect(result, false);
      expect(controller.errorMessage, contains('Gagal menghubungkan'));
    });
  });

  group('submitTopic', () {
    test('memanggil updateTopic dengan parameter yang benar', () async {
      when(() => mockWorkspaceService.updateTopic(
            'ws-1', 'Topik Baru',
            topicDescription: 'Deskripsi',
          )).thenAnswer((_) async {});

      await controller.submitTopic('ws-1', 'Topik Baru', 'Deskripsi');

      verify(() => mockWorkspaceService.updateTopic(
            'ws-1', 'Topik Baru',
            topicDescription: 'Deskripsi',
          )).called(1);
      expect(controller.errorMessage, isNull);
    });

    test('menyimpan errorMessage bila updateTopic gagal', () async {
      when(() => mockWorkspaceService.updateTopic(
            any(), any(),
            topicDescription: any(named: 'topicDescription'),
          )).thenThrow(Exception('DB error'));

      await controller.submitTopic('ws-1', 'Topik', 'Desc');

      expect(controller.errorMessage, contains('Gagal mengajukan topik'));
    });
  });

  group('createPhase', () {
    test('menambahkan phase baru ke allPhases setelah berhasil dibuat', () async {
      when(() => mockPhaseService.createPhase(any()))
          .thenAnswer((_) async => _fakePhase());

      await controller.createPhase('ws-1', 'Phase Baru', 1);

      expect(controller.allPhases.length, 1);
    });

    test('menyimpan errorMessage bila createPhase gagal', () async {
      when(() => mockPhaseService.createPhase(any()))
          .thenThrow(Exception('DB error'));

      await controller.createPhase('ws-1', 'Phase Gagal', 2);

      expect(controller.errorMessage, contains('Gagal membuat phase'));
    });
  });

  group('createTaskAllocation', () {
    test('menambahkan task baru ke allTask setelah berhasil dibuat', () async {
      when(() => mockTaskService.createTask(any()))
          .thenAnswer((_) async => _fakeTask());

      await controller.createTaskAllocation('phase-1', 'student-1', 'Buat laporan');

      expect(controller.allTask.length, 1);
    });

    test('menyimpan errorMessage bila createTask gagal', () async {
      when(() => mockTaskService.createTask(any()))
          .thenThrow(Exception('DB error'));

      await controller.createTaskAllocation('phase-1', 'student-1', 'Buat laporan');

      expect(controller.errorMessage, contains('Gagal membuat task allocation'));
    });
  });

  group('createPhasesWithTasks', () {
    test('mengembalikan true dan mengisi allPhases serta allTask', () async {
      when(() => mockPhaseService.createPhase(any()))
          .thenAnswer((_) async => _fakePhase());
      when(() => mockTaskService.createTask(any()))
          .thenAnswer((_) async => _fakeTask());

      final result = await controller.createPhasesWithTasks('ws-1', [
        (
          phaseName: 'Phase 1',
          sortOrder: 1,
          deadline: null,
          tasks: [(studentId: 'student-1', taskDescription: 'Task A')],
        ),
      ]);

      expect(result, true);
      expect(controller.allPhases, isNotEmpty);
      expect(controller.allTask, isNotEmpty);
    });

    test('mengembalikan false bila phase gagal dibuat', () async {
      when(() => mockPhaseService.createPhase(any()))
          .thenThrow(Exception('DB error'));

      final result = await controller.createPhasesWithTasks('ws-1', [
        (
          phaseName: 'Phase X',
          sortOrder: 1,
          deadline: null,
          tasks: <({String studentId, String taskDescription})>[],
        ),
      ]);

      expect(result, false);
      expect(controller.errorMessage, contains('Gagal menyimpan phase'));
    });
  });

  group('getTasksByPhase', () {
    test('mengembalikan task yang sesuai phaseId', () async {
      when(() => mockTaskService.createTask(any()))
          .thenAnswer((_) async => _fakeTask(phaseId: 'phase-1'));

      await controller.createTaskAllocation('phase-1', 'student-1', 'Task A');

      expect(controller.getTasksByPhase('phase-1').length, 1);
    });

    test('mengembalikan list kosong bila tidak ada task di phase', () {
      expect(controller.getTasksByPhase('phase-non-exist'), isEmpty);
    });
  });

  group('getStudentName', () {
    test("mengembalikan 'Belum Ada' bila studentId tidak ditemukan", () {
      expect(controller.getStudentName('non-existent'), 'Belum Ada');
    });
  });

  group('dispose', () {
    test('tidak throw setelah dispose dipanggil', () {
      final c = WorkspaceDetailController(
        service: mockWorkspaceService,
        phaseService: mockPhaseService,
        taskService: mockTaskService,
      );
      expect(() => c.dispose(), returnsNormally);
    });

    test('notifyListeners tidak throw setelah dispose', () {
      final c = WorkspaceDetailController(
        service: mockWorkspaceService,
        phaseService: mockPhaseService,
        taskService: mockTaskService,
      );
      c.dispose();
      expect(() => c.notifyListeners(), returnsNormally);
    });
  });
}