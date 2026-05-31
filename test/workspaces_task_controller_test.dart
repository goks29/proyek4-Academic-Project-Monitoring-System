import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:academic_project_monitoring_system/features/academic/student/workspace_task_controller.dart';
import 'package:academic_project_monitoring_system/models/task_allocation_model.dart';
import 'package:academic_project_monitoring_system/models/submission_model.dart';
import 'package:academic_project_monitoring_system/models/pending_submission_model.dart';
import 'package:academic_project_monitoring_system/services/remote/task_service.dart';
import 'package:academic_project_monitoring_system/services/remote/submission_service.dart';
import 'package:academic_project_monitoring_system/core/offline/offline_submission_manager.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class MockTaskService extends Mock implements TaskService {}
class MockSubmissionService extends Mock implements SubmissionService {}
class MockOfflineSubmissionManager extends Mock implements OfflineSubmissionManager {}
class MockXFile extends Mock implements XFile {}

// Fake untuk registerFallbackValue
class FakeTaskAllocationModel extends Fake implements TaskAllocationModel {}

// ── Fake builders ──────────────────────────────────────────────────────────

TaskAllocationModel _fakeTask({
  String id = 'task-1',
  String phaseId = 'phase-1',
  int progress = 0,
  bool isDone = false,
}) =>
    TaskAllocationModel(
      id: id,
      phaseId: phaseId,
      studentId: 'student-1',
      taskDescription: 'Kerjakan sesuatu',
      isDone: isDone,
      status: isDone ? 'done' : 'pending',
      clientCreatedAt: DateTime(2024, 1, 1),
      progress: progress,
    );

SubmissionModel _fakeSubmission({String taskId = 'task-1'}) => SubmissionModel(
      id: 'sub-1',
      taskId: taskId,
      studentId: 'student-1',
      submittedAt: DateTime(2024, 6, 1),
      status: 'submitted',
    );

PendingSubmissionModel _fakePending({String taskId = 'task-1'}) =>
    PendingSubmissionModel(
      id: 'pending-1',
      taskId: taskId,
      studentId: 'student-1',
      localFilePath: '/tmp/file.pdf',
      fileHash: 'abc123hash',
      estimatedSubmitAt: DateTime(2024, 6, 1),
      syncNonce: 'nonce-uuid-1',
      notes: 'Menunggu sync',
      fileName: 'file.pdf',
      mimeType: 'application/pdf',
      tokenUserId: 'student-1',
      tokenDeviceId: 'device-001',
      tokenServerTime: DateTime(2024, 6, 1),
      tokenMonotonicAtIssue: 123456,
      tokenExpiresAt: DateTime(2024, 6, 2),
      tokenSignature: 'sig-abc',
      createdAt: DateTime(2024, 6, 1),
    );

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  late WorkspaceTaskController controller;
  late MockTaskService mockTaskService;
  late MockSubmissionService mockSubmissionService;
  late MockOfflineSubmissionManager mockOfflineManager;

  setUpAll(() {
    registerFallbackValue(FakeTaskAllocationModel());

    // Inisialisasi Hive untuk environment test
    final tempDir = Directory.systemTemp.createTempSync('hive_task_test_');
    Hive.init(tempDir.path);
  });

  setUp(() {
    mockTaskService = MockTaskService();
    mockSubmissionService = MockSubmissionService();
    mockOfflineManager = MockOfflineSubmissionManager();

    controller = WorkspaceTaskController(
      taskService: mockTaskService,
      submissionService: mockSubmissionService,
    );

    addTearDown(() => controller.dispose());
  });

  // ── setPhaseDeadline / isDeadlinePassed ────────────────────────────────────

  group('setPhaseDeadline / isDeadlinePassed', () {
    test('isDeadlinePassed = false bila deadline null', () {
      expect(controller.isDeadlinePassed, false);
    });

    test('isDeadlinePassed = false bila deadline di masa depan', () {
      controller.setPhaseDeadline(DateTime.now().add(const Duration(days: 7)));
      expect(controller.isDeadlinePassed, false);
    });

    test('isDeadlinePassed = true bila deadline sudah lewat', () {
      controller.setPhaseDeadline(DateTime.now().subtract(const Duration(days: 1)));
      expect(controller.isDeadlinePassed, true);
    });

    test('notifyListeners dipanggil saat setPhaseDeadline', () {
      bool notified = false;
      controller.addListener(() => notified = true);
      controller.setPhaseDeadline(DateTime.now());
      expect(notified, true);
    });
  });

  // ── loadTask ───────────────────────────────────────────────────────────────

  group('loadTask', () {
    test('memuat task dan submissions dengan sukses', () async {
      final task = _fakeTask();
      when(() => mockTaskService.getTaskById('task-1'))
          .thenAnswer((_) async => task);
      when(() => mockSubmissionService.getSubmissionsByTask('task-1'))
          .thenAnswer((_) async => [_fakeSubmission()]);

      await controller.loadTask(task);

      expect(controller.task?.id, 'task-1');
      expect(controller.submissions.length, 1);
      expect(controller.isLoading, false);
    });

    test('menggunakan initialTask bila getTaskById mengembalikan null', () async {
      final initialTask = _fakeTask(progress: 30);
      when(() => mockTaskService.getTaskById('task-1'))
          .thenAnswer((_) async => null);
      when(() => mockSubmissionService.getSubmissionsByTask('task-1'))
          .thenAnswer((_) async => []);

      await controller.loadTask(initialTask);

      expect(controller.task?.progress, 30);
    });

    test('memuat pendingSubmissions dari offlineManager bila tersedia', () async {
      controller.setOfflineManager(mockOfflineManager);
      final task = _fakeTask();
      when(() => mockTaskService.getTaskById('task-1'))
          .thenAnswer((_) async => task);
      when(() => mockSubmissionService.getSubmissionsByTask('task-1'))
          .thenAnswer((_) async => []);
      when(() => mockOfflineManager.getPendingByTaskId('task-1'))
          .thenReturn([_fakePending()]);

      await controller.loadTask(task);

      expect(controller.pendingSubmissions.length, 1);
    });

    test('isLoading berubah true lalu false selama loadTask', () async {
      final states = <bool>[];
      final task = _fakeTask();
      when(() => mockTaskService.getTaskById(any()))
          .thenAnswer((_) async => task);
      when(() => mockSubmissionService.getSubmissionsByTask(any()))
          .thenAnswer((_) async => []);

      controller.addListener(() => states.add(controller.isLoading));
      await controller.loadTask(task);

      expect(states.first, true);
      expect(states.last, false);
    });
  });

  // ── updateProgress ─────────────────────────────────────────────────────────

  group('updateProgress', () {
    setUp(() async {
      final task = _fakeTask();
      when(() => mockTaskService.getTaskById('task-1'))
          .thenAnswer((_) async => task);
      when(() => mockSubmissionService.getSubmissionsByTask('task-1'))
          .thenAnswer((_) async => []);
      await controller.loadTask(task);
    });

    test('berhasil mengupdate progress secara online', () async {
      when(() => mockTaskService.updateTaskProgress('task-1', 60))
          .thenAnswer((_) async {});
      when(() => mockTaskService.updateTaskStatus('task-1', false))
          .thenAnswer((_) async {});

      final result = await controller.updateProgress('task-1', 60);

      expect(result, true);
      expect(controller.task?.progress, 60);
      expect(controller.task?.isDone, false);
    });

    test('isDone menjadi true bila progress = 100', () async {
      when(() => mockTaskService.updateTaskProgress('task-1', 100))
          .thenAnswer((_) async {});
      when(() => mockTaskService.updateTaskStatus('task-1', true))
          .thenAnswer((_) async {});

      final result = await controller.updateProgress('task-1', 100);

      expect(result, true);
      expect(controller.task?.isDone, true);
    });

    test('mengembalikan false dan errorMessage bila deadline sudah lewat', () async {
      controller.setPhaseDeadline(
          DateTime.now().subtract(const Duration(hours: 1)));

      final result = await controller.updateProgress('task-1', 50);

      expect(result, false);
      expect(controller.errorMessage, contains('Deadline'));
    });

    test('isSavingProgress kembali false setelah selesai', () async {
      when(() => mockTaskService.updateTaskProgress(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockTaskService.updateTaskStatus(any(), any()))
          .thenAnswer((_) async {});

      await controller.updateProgress('task-1', 70);

      expect(controller.isSavingProgress, false);
    });
  });

  // ── submitEvidence ─────────────────────────────────────────────────────────

  group('submitEvidence', () {
    late MockXFile mockFile;

    setUp(() async {
      mockFile = MockXFile();
      final task = _fakeTask();
      when(() => mockTaskService.getTaskById('task-1'))
          .thenAnswer((_) async => task);
      when(() => mockSubmissionService.getSubmissionsByTask('task-1'))
          .thenAnswer((_) async => []);
      await controller.loadTask(task);
    });

    test('mengembalikan false dan errorMessage bila deadline sudah lewat', () async {
      controller.setPhaseDeadline(
          DateTime.now().subtract(const Duration(hours: 1)));

      final result = await controller.submitEvidence(
        taskId: 'task-1',
        studentId: 'student-1',
        file: mockFile,
        notes: 'Catatan',
      );

      expect(result, false);
      expect(controller.errorMessage, contains('Deadline'));
    });

    test('menambahkan submission ke list bila online berhasil (tanpa offlineManager)',
        () async {
      when(() => mockSubmissionService.uploadEvidenceAndSubmit(
            taskId: 'task-1',
            studentId: 'student-1',
            file: mockFile,
            notes: 'Catatan',
          )).thenAnswer((_) async => _fakeSubmission());

      final result = await controller.submitEvidence(
        taskId: 'task-1',
        studentId: 'student-1',
        file: mockFile,
        notes: 'Catatan',
      );

      expect(result, true);
      expect(controller.submissions.length, 1);
    });

    test('menambahkan submission ke list saat online via offlineManager', () async {
      controller.setOfflineManager(mockOfflineManager);
      when(() => mockOfflineManager.submitEvidence(
            taskId: 'task-1',
            studentId: 'student-1',
            file: mockFile,
            notes: 'Catatan',
          )).thenAnswer((_) async => _fakeSubmission());
      when(() => mockOfflineManager.getPendingByTaskId(any())).thenReturn([]);

      final result = await controller.submitEvidence(
        taskId: 'task-1',
        studentId: 'student-1',
        file: mockFile,
        notes: 'Catatan',
      );

      expect(result, true);
      expect(controller.submissions.length, 1);
    });
  });

  // ── hasPendingSync ─────────────────────────────────────────────────────────

  group('hasPendingSync', () {
    test('mengembalikan false bila tidak ada pending submission', () {
      expect(controller.hasPendingSync, false);
    });

    test('mengembalikan true bila ada pending submission', () {
      controller.setOfflineManager(mockOfflineManager);
      when(() => mockOfflineManager.getPendingByTaskId(any()))
          .thenReturn([_fakePending()]);
      controller.refreshPendingSubmissions('task-1');

      expect(controller.hasPendingSync, true);
    });
  });

  // ── isSaving convenience getter ────────────────────────────────────────────

  group('isSaving', () {
    test('mengembalikan false bila tidak ada operasi simpan berjalan', () {
      expect(controller.isSaving, false);
    });
  });

  // ── dispose ────────────────────────────────────────────────────────────────

  group('dispose', () {
    test('tidak throw setelah dispose dipanggil', () {
      final c = WorkspaceTaskController(
        taskService: mockTaskService,
        submissionService: mockSubmissionService,
      );
      expect(() => c.dispose(), returnsNormally);
    });

    test('notifyListeners tidak throw setelah dispose', () {
      final c = WorkspaceTaskController(
        taskService: mockTaskService,
        submissionService: mockSubmissionService,
      );
      c.dispose();
      expect(() => c.notifyListeners(), returnsNormally);
    });
  });
}