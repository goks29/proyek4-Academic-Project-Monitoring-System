// lib/features/academic/lecturer/lecturer_controller.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/project_model.dart';
import '../../../models/workspace_model.dart';
import '../../../services/project_service.dart';
import '../../../services/workspace_service.dart';
import 'package:uuid/uuid.dart';

class LecturerController {
  // Gunakan instance client yang benar
  final ProjectService _projectService = ProjectService(
    Supabase.instance.client,
  );
  final WorkspaceService _workspaceService = WorkspaceService(
    Supabase.instance.client,
  );

  // Fungsi yang dipanggil oleh FutureBuilder di View
  Future<List<ProjectModel>> getAllProjects() async {
    try {
      final result = await _projectService.getProjects();
      return result;
    } catch (e) {
      // Jika koneksi ditolak, kita print alamat yang dicoba diakses
      print(
        "DEBUG ERROR: Gagal konek ke Supabase. Pastikan URL benar! Error: $e",
      );
      return [];
    }
  }

  Future<List<WorkspaceModel>> getWorkspacesByProject(String projectId) async {
    try {
      return await _workspaceService.getWorkspacesByProject(projectId);
    } catch (e) {
      print("DEBUG ERROR: Gagal ambil kelompok: $e");
      return [];
    }
  }

  double calculateProgress(WorkspaceModel workspace) {
    return 0.7; // Progress dummy 70%
  }

  Future<String?> createProject(String title, String description, String? finalInfo) async {
  try {
    final String lecturerId = Supabase.instance.client.auth.currentUser?.id ?? "d05e0001-0000-0000-0000-000000000000";
    final String joinCode = _generateRandomCode(); // Generate di sini

    final newProject = ProjectModel(
      id: const Uuid().v4(),
      lecturerId: lecturerId,
      title: title,
      description: description,
      joinCode: joinCode,
      finalSubmissionInfo: finalInfo,
    );

    await _projectService.createProject(newProject);
    return joinCode; // Kembalikan kodenya
  } catch (e) {
    print("Gagal membuat proyek: $e");
    return null;
  }
}

  String _generateRandomCode() {
    return (1000 + (9999 - 1000) * (DateTime.now().millisecond / 1000))
        .toInt()
        .toString();
  }
}
