import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:academic_project_monitoring_system/controllers/lecturer/task_approval_controller.dart';
import 'package:academic_project_monitoring_system/models/task_allocation_model.dart';
import 'package:academic_project_monitoring_system/repositories/task_repository.dart';

// Mock //

class MockTaskRepository extends Mock implements TaskRepository {}

// Data Dummy //

TaskAllocationModel _fakeTask({
  String id = 'task-1',
  String status = 'pending',
  bool requireEvidence = false,
}) =>
    TaskAllocationModel(
      id: id,
      phaseId: 'phase-1',
      studentId: 'student-1',
      taskDescription: 'Buat laporan',
      isDone: false,
      status: status,
      requireEvidence: requireEvidence,
      clientCreatedAt: DateTime(2024, 1, 1),
    );

void main() {
  late TaskApprovalController controller;
  late MockTaskRepository mockRepo;

  setUp(() {
    mockRepo = MockTaskRepository();
    controller = TaskApprovalController(mockRepo);
  });

  tearDown(() => controller.dispose());

  group('fetchTasks', () {
    test('memuat daftar task berdasarkan phase id', () async {
      when(() => mockRepo.getTasks('phase-1'))
          .thenAnswer((_) async => [_fakeTask(), _fakeTask(id: 'task-2')]);

      await controller.fetchTasks('phase-1');

      expect(controller.tasks.length, 2);
      expect(controller.isLoading, false);
    });

    test('menyimpan errorMessage bila fetch gagal', () async {
      when(() => mockRepo.getTasks(any()))
          .thenThrow(Exception('Network error'));

      await controller.fetchTasks('phase-1');

      expect(controller.errorMessage, contains('Network error'));
    });

    test('isLoading berubah true lalu false selama fetch', () async {
      final states = <bool>[];
      controller.addListener(() => states.add(controller.isLoading));
      when(() => mockRepo.getTasks(any())).thenAnswer((_) async => []);

      await controller.fetchTasks('phase-1');

      expect(states.first, true);
      expect(states.last, false);
    });
  });

  group('approveTask', () {
    setUp(() async {
      when(() => mockRepo.getTasks('phase-1'))
          .thenAnswer((_) async => [_fakeTask()]);
      await controller.fetchTasks('phase-1');
    });

    test('mengubah status task menjadi approved', () async {
      when(() => mockRepo.approveTaskStatus('task-1', 'approved', feedback: 'Baik'))
          .thenAnswer((_) async {});

      await controller.approveTask('task-1', 'approved', feedback: 'Baik');

      expect(controller.tasks.first.status, 'approved');
      expect(controller.tasks.first.lecturerFeedback, 'Baik');
    });

    test('mengubah status task menjadi rejected', () async {
      when(() => mockRepo.approveTaskStatus('task-1', 'rejected', feedback: 'Kurang'))
          .thenAnswer((_) async {});

      await controller.approveTask('task-1', 'rejected', feedback: 'Kurang');

      expect(controller.tasks.first.status, 'rejected');
    });

    test('menyimpan errorMessage bila approve gagal', () async {
      when(() => mockRepo.approveTaskStatus(any(), any(), feedback: any(named: 'feedback')))
          .thenThrow(Exception('DB error'));

      await controller.approveTask('task-1', 'approved');

      expect(controller.errorMessage, contains('DB error'));
    });

    test('tidak mengubah data bila taskId tidak ditemukan', () async {
      when(() => mockRepo.approveTaskStatus('task-unknown', 'approved', feedback: null))
          .thenAnswer((_) async {});

      await controller.approveTask('task-unknown', 'approved');

      expect(controller.tasks.first.status, 'pending');
    });
  });

  group('updateRequireEvidence', () {
    setUp(() async {
      when(() => mockRepo.getTasks('phase-1'))
          .thenAnswer((_) async => [_fakeTask(requireEvidence: false)]);
      await controller.fetchTasks('phase-1');
    });

    test('mengubah requireEvidence menjadi true', () async {
      when(() => mockRepo.updateTask('task-1', any()))
          .thenAnswer((_) async {});

      await controller.updateRequireEvidence('task-1', true);

      expect(controller.tasks.first.requireEvidence, true);
    });

    test('mengubah requireEvidence menjadi false', () async {
      // Set true dulu
      when(() => mockRepo.updateTask('task-1', any()))
          .thenAnswer((_) async {});
      await controller.updateRequireEvidence('task-1', true);

      await controller.updateRequireEvidence('task-1', false);

      expect(controller.tasks.first.requireEvidence, false);
    });

    test('menyimpan errorMessage bila update gagal', () async {
      when(() => mockRepo.updateTask(any(), any()))
          .thenThrow(Exception('Update error'));

      await controller.updateRequireEvidence('task-1', true);

      expect(controller.errorMessage, contains('Update error'));
    });
  });
}
