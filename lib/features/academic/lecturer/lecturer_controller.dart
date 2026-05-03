import 'package:supabase_flutter/supabase_flutter.dart';
// HAPUS import 'package:uuid/uuid.dart'; karena kita tidak pakai UUID lagi

import '../../../models/project_model.dart';
import '../../../models/workspace_model.dart';
import '../../../models/progress_phase_model.dart';

// Import SERVICES (Arahkan workspace_service ke folder remote yang baru)
import '../../../services/remote/phase_service.dart';
import '../../../services/remote/workspace_service.dart'; // <--- UBAH IMPORT INI
import '../../../services/remote/project_service.dart';
import '../../../services/remote/user_service.dart';
import '../../../services/remote/workspace_member_service.dart';
import 'dart:math'; // <--- TAMBAHKAN UNTUK RANDOM CODE

class LecturerController {
  final ProjectService _projectService = ProjectService(Supabase.instance.client);
  final WorkspaceService _workspaceService = WorkspaceService(Supabase.instance.client);
  final UserService _userService = UserService(Supabase.instance.client);
  final WorkspaceMemberService _memberService = WorkspaceMemberService(Supabase.instance.client);
  final PhaseService _phaseService = PhaseService(Supabase.instance.client);

  Future<List<ProjectModel>> getAllProjects() async {
    try {
      return await _projectService.getProjects();
    } catch (e) {
      print("DEBUG ERROR: Gagal ambil proyek: $e");
      return [];
    }
  }

  // ---> UBAH FUNGSI INI DARI getWorkspacesByProject MENJADI getWorkspacesByJoinCode <---
  Future<List<WorkspaceModel>> getWorkspacesByJoinCode(String joinCode) async {
    try {
      return await _workspaceService.getWorkspacesByJoinCode(joinCode);
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
      
      // ---> UBAH CARA PEMBUATAN PROJECTMODEL (Hilangkan id) <---
      final newProject = ProjectModel(
        joinCode: joinCode, // id diganti jadi joinCode
        lecturerId: lecturerId,
        title: title,
        description: description,
        finalSubmissionInfo: finalInfo,
        createdAt: DateTime.now(),
      );
      
      await _projectService.createProject(newProject);
      return joinCode;
    } catch (e) {
      print("Gagal membuat proyek: $e");
      return null;
    }
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<List<Map<String, dynamic>>> getWorkspaceMembersDetails(String workspaceId) async {
    try {
      final members = await _memberService.getMembers(workspaceId);
      List<Map<String, dynamic>> detailedMembers = [];
      
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
      return await _phaseService.getPhases(workspaceId);
    } catch (e) {
      print("Error fetching phases: $e");
      return [];
    }
  }
}