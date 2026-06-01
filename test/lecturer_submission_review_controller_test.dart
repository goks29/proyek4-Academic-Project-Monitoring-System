import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:academic_project_monitoring_system/controllers/lecturer/submission_review_controller.dart';
import 'package:academic_project_monitoring_system/models/submission_model.dart';
import 'package:academic_project_monitoring_system/repositories/submission_repository.dart';

// Mock //

class MockSubmissionRepository extends Mock implements SubmissionRepository {}

// Data Dummy //

SubmissionModel _fakeSubmission({
  String id = 'sub-1',
  String status = 'submitted',
}) =>
    SubmissionModel(
      id: id,
      taskId: 'task-1',
      studentId: 'student-1',
      submittedAt: DateTime(2024, 6, 1),
      status: status,
    );

void main() {
  late SubmissionReviewController controller;
  late MockSubmissionRepository mockRepo;

  setUp(() {
    mockRepo = MockSubmissionRepository();
    controller = SubmissionReviewController(mockRepo);
  });

  tearDown(() => controller.dispose());

  group('fetchSubmissions', () {
    test('memuat daftar submission berdasarkan task id', () async {
      when(() => mockRepo.getSubmissionsByTaskId('task-1'))
          .thenAnswer((_) async => [_fakeSubmission()]);

      await controller.fetchSubmissions('task-1');

      expect(controller.submissions.length, 1);
      expect(controller.isLoading, false);
    });

    test('menyimpan errorMessage bila fetch gagal', () async {
      when(() => mockRepo.getSubmissionsByTaskId(any()))
          .thenThrow(Exception('Network error'));

      await controller.fetchSubmissions('task-1');

      expect(controller.errorMessage, contains('Network error'));
    });

    test('mengembalikan list kosong bila tidak ada submission', () async {
      when(() => mockRepo.getSubmissionsByTaskId('task-empty'))
          .thenAnswer((_) async => []);

      await controller.fetchSubmissions('task-empty');

      expect(controller.submissions, isEmpty);
    });

    test('isLoading berubah true lalu false selama fetch', () async {
      final states = <bool>[];
      controller.addListener(() => states.add(controller.isLoading));
      when(() => mockRepo.getSubmissionsByTaskId(any()))
          .thenAnswer((_) async => []);

      await controller.fetchSubmissions('task-1');

      expect(states.first, true);
      expect(states.last, false);
    });
  });

  group('reviewSubmission', () {
    setUp(() async {
      when(() => mockRepo.getSubmissionsByTaskId('task-1'))
          .thenAnswer((_) async => [_fakeSubmission()]);
      await controller.fetchSubmissions('task-1');
    });

    test('mengubah status submission menjadi approved dengan feedback', () async {
      when(() => mockRepo.reviewSubmission('sub-1', 'approved', 'Baik', 'lecturer-1'))
          .thenAnswer((_) async {});

      await controller.reviewSubmission('sub-1', 'approved', 'Baik', 'lecturer-1');

      expect(controller.submissions.first.status, 'approved');
      expect(controller.submissions.first.lecturerFeedback, 'Baik');
      expect(controller.submissions.first.lecturerId, 'lecturer-1');
    });

    test('mengubah status submission menjadi rejected', () async {
      when(() => mockRepo.reviewSubmission('sub-1', 'rejected', 'Revisi', 'lecturer-1'))
          .thenAnswer((_) async {});

      await controller.reviewSubmission('sub-1', 'rejected', 'Revisi', 'lecturer-1');

      expect(controller.submissions.first.status, 'rejected');
    });

    test('menyimpan errorMessage bila review gagal', () async {
      when(() => mockRepo.reviewSubmission(any(), any(), any(), any()))
          .thenThrow(Exception('DB error'));

      await controller.reviewSubmission('sub-1', 'approved', 'Feedback', 'lecturer-1');

      expect(controller.errorMessage, contains('DB error'));
    });

    test('tidak mengubah data bila submissionId tidak ditemukan', () async {
      when(() => mockRepo.reviewSubmission('sub-unknown', 'approved', 'OK', 'lecturer-1'))
          .thenAnswer((_) async {});

      await controller.reviewSubmission('sub-unknown', 'approved', 'OK', 'lecturer-1');

      expect(controller.submissions.first.status, 'submitted');
    });
  });
}
