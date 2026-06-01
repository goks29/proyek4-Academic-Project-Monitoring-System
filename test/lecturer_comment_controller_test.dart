import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:academic_project_monitoring_system/controllers/lecturer/comment_controller.dart';
import 'package:academic_project_monitoring_system/models/comment_model.dart';
import 'package:academic_project_monitoring_system/repositories/comment_repository.dart';

// Mock //

class MockCommentRepository extends Mock implements CommentRepository {}
class FakeCommentModel extends Fake implements CommentModel {}

// Data Dummy //

CommentModel _fakeComment({
  String id = 'comment-1',
  String? phaseId = 'phase-1',
  String? taskId,
}) =>
    CommentModel(
      id: id,
      phaseId: phaseId,
      taskId: taskId,
      userId: 'lecturer-1',
      commentText: 'Komentar dosen',
      clientCreatedAt: DateTime(2024, 6, 1),
    );

void main() {
  late CommentController controller;
  late MockCommentRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(FakeCommentModel());
  });

  setUp(() {
    mockRepo = MockCommentRepository();
    controller = CommentController(mockRepo);
  });

  tearDown(() => controller.dispose());

  group('fetchCommentsByPhase', () {
    test('memuat daftar komentar berdasarkan phase id', () async {
      when(() => mockRepo.getCommentsByPhaseId('phase-1'))
          .thenAnswer((_) async => [_fakeComment()]);

      await controller.fetchCommentsByPhase('phase-1');

      expect(controller.comments.length, 1);
      expect(controller.isLoading, false);
    });

    test('menyimpan errorMessage bila fetch gagal', () async {
      when(() => mockRepo.getCommentsByPhaseId(any()))
          .thenThrow(Exception('Network error'));

      await controller.fetchCommentsByPhase('phase-1');

      expect(controller.errorMessage, contains('Network error'));
    });

    test('isLoading berubah true lalu false selama fetch', () async {
      final states = <bool>[];
      controller.addListener(() => states.add(controller.isLoading));
      when(() => mockRepo.getCommentsByPhaseId(any()))
          .thenAnswer((_) async => []);

      await controller.fetchCommentsByPhase('phase-1');

      expect(states.first, true);
      expect(states.last, false);
    });
  });

  group('fetchCommentsByTask', () {
    test('memuat daftar komentar berdasarkan task id', () async {
      when(() => mockRepo.getCommentsByTaskId('task-1'))
          .thenAnswer((_) async => [_fakeComment(taskId: 'task-1', phaseId: null)]);

      await controller.fetchCommentsByTask('task-1');

      expect(controller.comments.length, 1);
    });

    test('menyimpan errorMessage bila fetch gagal', () async {
      when(() => mockRepo.getCommentsByTaskId(any()))
          .thenThrow(Exception('Timeout'));

      await controller.fetchCommentsByTask('task-1');

      expect(controller.errorMessage, contains('Timeout'));
    });
  });

  group('addComment', () {
    test('menambahkan komentar baru ke list', () async {
      final newComment = _fakeComment(id: 'comment-new');
      when(() => mockRepo.createComment(any()))
          .thenAnswer((_) async => newComment);

      await controller.addComment(newComment);

      expect(controller.comments.length, 1);
      expect(controller.comments.first.id, 'comment-new');
    });

    test('menyimpan errorMessage bila addComment gagal', () async {
      when(() => mockRepo.createComment(any()))
          .thenThrow(Exception('DB error'));

      await controller.addComment(_fakeComment());

      expect(controller.errorMessage, contains('DB error'));
    });

    test('notifyListeners dipanggil setelah berhasil add', () async {
      bool notified = false;
      controller.addListener(() => notified = true);
      when(() => mockRepo.createComment(any()))
          .thenAnswer((_) async => _fakeComment());

      await controller.addComment(_fakeComment());

      expect(notified, true);
    });
  });
}
