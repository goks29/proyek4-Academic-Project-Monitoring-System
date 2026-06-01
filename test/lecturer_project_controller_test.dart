import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:academic_project_monitoring_system/controllers/lecturer/project_controller.dart';
import 'package:academic_project_monitoring_system/models/project_model.dart';
import 'package:academic_project_monitoring_system/repositories/project_repository.dart';

// Mock //

class MockProjectRepository extends Mock implements ProjectRepository {}
class FakeProjectModel extends Fake implements ProjectModel {}

// Data Dummy //

ProjectModel _fakeProject({
  String joinCode = 'ABC123',
  bool isActive = true,
}) =>
    ProjectModel(
      joinCode: joinCode,
      lecturerId: 'lecturer-1',
      title: 'Proyek Akhir',
      description: 'Deskripsi proyek',
      isActive: isActive,
      createdAt: DateTime(2024, 1, 1),
    );

void main() {
  late ProjectController controller;
  late MockProjectRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(FakeProjectModel());
  });

  setUp(() {
    mockRepo = MockProjectRepository();
    controller = ProjectController(mockRepo);
  });

  tearDown(() => controller.dispose());

  group('fetchProjects', () {
    test('memuat daftar proyek dari repository', () async {
      when(() => mockRepo.getProjects())
          .thenAnswer((_) async => [_fakeProject(), _fakeProject(joinCode: 'DEF456')]);

      await controller.fetchProjects();

      expect(controller.projects.length, 2);
      expect(controller.isLoading, false);
      expect(controller.errorMessage, isNull);
    });

    test('menyimpan errorMessage bila fetchProjects gagal', () async {
      when(() => mockRepo.getProjects())
          .thenThrow(Exception('Network error'));

      await controller.fetchProjects();

      expect(controller.errorMessage, contains('Network error'));
      expect(controller.isLoading, false);
    });

    test('isLoading berubah true lalu false selama fetch', () async {
      final states = <bool>[];
      controller.addListener(() => states.add(controller.isLoading));
      when(() => mockRepo.getProjects()).thenAnswer((_) async => []);

      await controller.fetchProjects();

      expect(states.first, true);
      expect(states.last, false);
    });
  });

  group('onProgressProjectCount / completedProjectCount', () {
    test('menghitung proyek aktif dan selesai dengan benar', () async {
      when(() => mockRepo.getProjects()).thenAnswer((_) async => [
            _fakeProject(isActive: true),
            _fakeProject(joinCode: 'B', isActive: true),
            _fakeProject(joinCode: 'C', isActive: false),
          ]);

      await controller.fetchProjects();

      expect(controller.onProgressProjectCount, 2);
      expect(controller.completedProjectCount, 1);
    });

    test('mengembalikan 0 bila tidak ada proyek', () {
      expect(controller.onProgressProjectCount, 0);
      expect(controller.completedProjectCount, 0);
    });
  });

  group('createProject', () {
    test('menambahkan proyek baru dan mengembalikan true', () async {
      when(() => mockRepo.createProject(any()))
          .thenAnswer((_) async => _fakeProject());

      final result = await controller.createProject(
        'lecturer-1', 'Proyek Baru', 'Deskripsi', null,
      );

      expect(result, true);
      expect(controller.projects.length, 1);
    });

    test('mengembalikan false dan errorMessage bila gagal', () async {
      when(() => mockRepo.createProject(any()))
          .thenThrow(Exception('DB error'));

      final result = await controller.createProject(
        'lecturer-1', 'Proyek Gagal', 'Deskripsi', null,
      );

      expect(result, false);
      expect(controller.errorMessage, contains('DB error'));
    });
  });

  group('updateProject', () {
    test('memanggil repository.updateProject dan refresh data', () async {
      when(() => mockRepo.updateProject(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockRepo.getProjects())
          .thenAnswer((_) async => [_fakeProject()]);

      await controller.updateProject('ABC123', title: 'Updated Title');

      verify(() => mockRepo.updateProject('ABC123', any())).called(1);
    });

    test('menyimpan errorMessage bila update gagal', () async {
      when(() => mockRepo.updateProject(any(), any()))
          .thenThrow(Exception('Update failed'));

      await controller.updateProject('ABC123', title: 'Gagal');

      expect(controller.errorMessage, contains('Update failed'));
    });
  });

  group('closeProject', () {
    test('mengubah status proyek menjadi tidak aktif', () async {
      when(() => mockRepo.getProjects())
          .thenAnswer((_) async => [_fakeProject()]);
      await controller.fetchProjects();

      when(() => mockRepo.closeProject('ABC123'))
          .thenAnswer((_) async {});

      await controller.closeProject('ABC123');

      expect(controller.projects.first.isActive, false);
    });

    test('menyimpan errorMessage bila close gagal', () async {
      when(() => mockRepo.closeProject('ABC123'))
          .thenThrow(Exception('Close failed'));

      await controller.closeProject('ABC123');

      expect(controller.errorMessage, contains('Close failed'));
    });
  });
}
