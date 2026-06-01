import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:academic_project_monitoring_system/controllers/lecturer/topic_approval_controller.dart';
import 'package:academic_project_monitoring_system/models/workspace_model.dart';
import 'package:academic_project_monitoring_system/repositories/workspace_repository.dart';

// Mock //

class MockWorkspaceRepository extends Mock implements WorkspaceRepository {}

// Data Dummy //

WorkspaceModel _fakeWorkspace({
  String id = 'ws-1',
  String? status,
}) =>
    WorkspaceModel(
      id: id,
      joinCode: 'ABC123',
      teamName: 'Team Alpha',
      topicName: 'Topik AI',
      topicDescription: 'Deskripsi topik',
      status: status,
      progressionMode: 'strict',
      isCompleted: false,
      clientCreatedAt: DateTime(2024, 1, 1),
    );

void main() {
  late TopicApprovalController controller;
  late MockWorkspaceRepository mockRepo;

  setUp(() {
    mockRepo = MockWorkspaceRepository();
    controller = TopicApprovalController(mockRepo);
  });

  tearDown(() => controller.dispose());

  group('fetchWorkspacesByProject', () {
    test('memuat daftar workspace berdasarkan join code', () async {
      when(() => mockRepo.getWorkspacesByJoinCode('ABC123'))
          .thenAnswer((_) async => [_fakeWorkspace()]);

      await controller.fetchWorkspacesByProject('ABC123');

      expect(controller.workspaces.length, 1);
      expect(controller.isLoading, false);
    });

    test('menyimpan errorMessage bila fetch gagal', () async {
      when(() => mockRepo.getWorkspacesByJoinCode(any()))
          .thenThrow(Exception('Network error'));

      await controller.fetchWorkspacesByProject('ABC123');

      expect(controller.errorMessage, contains('Network error'));
    });

    test('isLoading berubah true lalu false selama fetch', () async {
      final states = <bool>[];
      controller.addListener(() => states.add(controller.isLoading));
      when(() => mockRepo.getWorkspacesByJoinCode(any()))
          .thenAnswer((_) async => []);

      await controller.fetchWorkspacesByProject('ABC123');

      expect(states.first, true);
      expect(states.last, false);
    });
  });

  group('approveTopic', () {
    setUp(() async {
      when(() => mockRepo.getWorkspacesByJoinCode(any()))
          .thenAnswer((_) async => [_fakeWorkspace()]);
      await controller.fetchWorkspacesByProject('ABC123');
    });

    test('mengubah status topik workspace menjadi approved', () async {
      when(() => mockRepo.updateTopicStatus('ws-1', 'approved', 'Bagus'))
          .thenAnswer((_) async {});

      await controller.approveTopic('ws-1', 'approved', 'Bagus');

      expect(controller.workspaces.first.status, 'approved');
      expect(controller.workspaces.first.lecturerFeedback, 'Bagus');
    });

    test('mengubah status topik workspace menjadi rejected', () async {
      when(() => mockRepo.updateTopicStatus('ws-1', 'rejected', 'Kurang spesifik'))
          .thenAnswer((_) async {});

      await controller.approveTopic('ws-1', 'rejected', 'Kurang spesifik');

      expect(controller.workspaces.first.status, 'rejected');
    });

    test('menyimpan errorMessage bila approve gagal', () async {
      when(() => mockRepo.updateTopicStatus(any(), any(), any()))
          .thenThrow(Exception('DB error'));

      await controller.approveTopic('ws-1', 'approved', null);

      expect(controller.errorMessage, contains('DB error'));
    });

    test('tidak mengubah data bila workspaceId tidak ditemukan', () async {
      when(() => mockRepo.updateTopicStatus('ws-unknown', 'approved', null))
          .thenAnswer((_) async {});

      await controller.approveTopic('ws-unknown', 'approved', null);

      // Data workspace asli tetap tidak berubah
      expect(controller.workspaces.first.status, isNull);
    });
  });
}
