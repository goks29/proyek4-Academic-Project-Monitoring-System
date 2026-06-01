import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:academic_project_monitoring_system/controllers/lecturer/phase_approval_controller.dart';
import 'package:academic_project_monitoring_system/models/progress_phase_model.dart';
import 'package:academic_project_monitoring_system/repositories/phase_repository.dart';

// Mock //

class MockPhaseRepository extends Mock implements PhaseRepository {}

// Data Dummy //

ProgressPhaseModel _fakePhase({
  String id = 'phase-1',
  String status = 'pending',
}) =>
    ProgressPhaseModel(
      id: id,
      workspaceId: 'ws-1',
      phaseName: 'Phase 1',
      sortOrder: 1,
      status: status,
      clientCreatedAt: DateTime(2024, 1, 1),
    );

void main() {
  late PhaseApprovalController controller;
  late MockPhaseRepository mockRepo;

  setUp(() {
    mockRepo = MockPhaseRepository();
    controller = PhaseApprovalController(mockRepo);
  });

  tearDown(() => controller.dispose());

  group('fetchPhases', () {
    test('memuat daftar phase berdasarkan workspace id', () async {
      when(() => mockRepo.getPhases('ws-1'))
          .thenAnswer((_) async => [_fakePhase(), _fakePhase(id: 'phase-2')]);

      await controller.fetchPhases('ws-1');

      expect(controller.phases.length, 2);
      expect(controller.isLoading, false);
    });

    test('menyimpan errorMessage bila fetch gagal', () async {
      when(() => mockRepo.getPhases(any()))
          .thenThrow(Exception('Timeout'));

      await controller.fetchPhases('ws-1');

      expect(controller.errorMessage, contains('Timeout'));
    });

    test('isLoading berubah true lalu false selama fetch', () async {
      final states = <bool>[];
      controller.addListener(() => states.add(controller.isLoading));
      when(() => mockRepo.getPhases(any())).thenAnswer((_) async => []);

      await controller.fetchPhases('ws-1');

      expect(states.first, true);
      expect(states.last, false);
    });
  });

  group('approvePhase', () {
    setUp(() async {
      when(() => mockRepo.getPhases('ws-1'))
          .thenAnswer((_) async => [_fakePhase()]);
      await controller.fetchPhases('ws-1');
    });

    test('mengubah status phase menjadi approved dengan feedback', () async {
      when(() => mockRepo.approvePhase('phase-1', 'approved', 'Sudah sesuai'))
          .thenAnswer((_) async {});

      await controller.approvePhase('phase-1', 'approved', 'Sudah sesuai');

      expect(controller.phases.first.status, 'approved');
      expect(controller.phases.first.lecturerFeedback, 'Sudah sesuai');
    });

    test('mengubah status phase menjadi revision', () async {
      when(() => mockRepo.approvePhase('phase-1', 'revision', 'Perlu perbaikan'))
          .thenAnswer((_) async {});

      await controller.approvePhase('phase-1', 'revision', 'Perlu perbaikan');

      expect(controller.phases.first.status, 'revision');
    });

    test('menyimpan errorMessage bila approve gagal', () async {
      when(() => mockRepo.approvePhase(any(), any(), any()))
          .thenThrow(Exception('DB error'));

      await controller.approvePhase('phase-1', 'approved', 'Feedback');

      expect(controller.errorMessage, contains('DB error'));
    });

    test('tidak mengubah data bila phaseId tidak ditemukan', () async {
      when(() => mockRepo.approvePhase('phase-unknown', 'approved', 'OK'))
          .thenAnswer((_) async {});

      await controller.approvePhase('phase-unknown', 'approved', 'OK');

      expect(controller.phases.first.status, 'pending');
    });
  });
}
