// lib/features/academic/lecturer/lecturer_controller.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../models/project_model.dart';
import '../../../models/workspace_model.dart';
import '../../../models/progress_phase_model.dart'; // Import Model ini

// Import semua Service yang dibutuhkan
import '../../../services/project_service.dart';
import '../../../services/workspace_service.dart';
import '../../../services/user_service.dart'; // Import UserService
import '../../../services/workspace_member_service.dart'; // Import MemberService
import '../../../services/phase_service.dart'; // Import PhaseService

class LecturerController {
  // Inisialisasi masing-masing service secara mandiri
  final ProjectService _projectService = ProjectService(Supabase.instance.client);
  final WorkspaceService _workspaceService = WorkspaceService(Supabase.instance.client);
  final UserService _userService = UserService(Supabase.instance.client);
  final WorkspaceMemberService _memberService = WorkspaceMemberService(Supabase.instance.client);
  final PhaseService _phaseService = PhaseService(Supabase.instance.client);

  Future<List<ProjectModel>> getAllProjects() async {
    try {
      final result = await _projectService.getProjects();
      return result;
    } catch (e) {
      print("DEBUG ERROR: Gagal konek ke Supabase. Pastikan URL benar! Error: $e");
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
      final String joinCode = _generateRandomCode();

      final newProject = ProjectModel(
        id: const Uuid().v4(),
        lecturerId: lecturerId,
        title: title,
        description: description,
        joinCode: joinCode,
        finalSubmissionInfo: finalInfo,
      );

      await _projectService.createProject(newProject);
      return joinCode;
    } catch (e) {
      print("Gagal membuat proyek: $e");
      return null;
    }
  }

  String _generateRandomCode() {
    return (1000 + (9999 - 1000) * (DateTime.now().millisecond / 1000)).toInt().toString();
  }

  Future<List<Map<String, dynamic>>> getWorkspaceMembersDetails(String workspaceId) async {
    try {
      // 1. Ambil data dari tabel workspace_members menggunakan _memberService
      final members = await _memberService.getMembers(workspaceId);
      
      List<Map<String, dynamic>> detailedMembers = [];
      
      // 2. Loop untuk mengambil nama user dari tabel users menggunakan _userService
      for (var member in members) {
        final userProfile = await _userService.getUserProfile(member.studentId);
        detailedMembers.add({
          'role': member.isLeader ? 'Ketua' : 'Anggota',
          'name': userProfile.fullName,
          'email': userProfile.email,
        });
      }
      return detailedMembers;
    } catch (e) {
      print("Error fetching member details: $e");
      return [];
    }
  }

  Future<List<ProgressPhaseModel>> getWorkspacePhases(String workspaceId) async {
    try {
      // Mengambil dari tabel progress_phases menggunakan _phaseService
      return await _phaseService.getPhases(workspaceId);
    } catch (e) {
      print("Error fetching phases: $e");
      return [];
    }
  }
}