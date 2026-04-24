import 'package:academic_project_monitoring_system/features/academic/student/anggota_tubes_model.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'tubes_model.dart';

class ProjectService {
  final String _projectBoxName = 'projects';
  final String _memberBoxName = 'project_members';
  final _uuid = const Uuid();

  // Buat Tubes
  Future<String> createProject({
    required String title,
    required String description,
    required List<String> scope,
    required DateTime deadline,
    required String creatorId,
  }) async {
    var box = await Hive.openBox<TubesModel>(_projectBoxName);
    
    final projectId = _uuid.v4();
    final newProject = TubesModel(
      id: projectId,
      title: title,
      description: description,
      scope: scope,
      deadline: deadline,
      createdAt: DateTime.now(),
    );

    await box.put(projectId, newProject);
    
    // Pembuat tubes otomatis ketua kelompok
    await addMember(projectId, creatorId, 'Leader');
    
    return projectId;
  }

  // Tambah Anggota Kelompok
  Future<void> addMember(String projectId, String profileId, String role) async {
    var box = await Hive.openBox<AnggotaTubesModel>(_memberBoxName);
    
    final member = AnggotaTubesModel(
      projectId: projectId,
      profileId: profileId,
      role: role,
      joinedAt: DateTime.now(),
    );

    // Make composite key biar unik per tubes per member
    // Gabisa nambahin 1 mahasiswa di 1 tubes 2 kali
    await box.put('${projectId}_${profileId}', member);
  }
}