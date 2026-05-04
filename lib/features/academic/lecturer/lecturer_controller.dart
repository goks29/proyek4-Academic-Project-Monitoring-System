// lib/features/academic/lecturer/lecturer_controller.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/project_model.dart';
import '../../../models/workspace_model.dart';
import '../../../models/progress_phase_model.dart';
import '../../../models/user_model.dart';
import '../../../models/comment_model.dart';

// Import SERVICES 
import '../../../services/remote/phase_service.dart';
import '../../../services/remote/workspace_service.dart';
import '../../../services/remote/project_service.dart';
import '../../../services/remote/user_service.dart';
import '../../../services/remote/workspace_member_service.dart';
import '../../../services/remote/task_service.dart'; 
import '../../../services/remote/comment_service.dart';
import 'dart:math';

class LecturerController {
  final ProjectService _projectService = ProjectService(Supabase.instance.client);
  final WorkspaceService _workspaceService = WorkspaceService(Supabase.instance.client);
  final UserService _userService = UserService(Supabase.instance.client);
  final WorkspaceMemberService _memberService = WorkspaceMemberService(Supabase.instance.client);
  final PhaseService _phaseService = PhaseService(Supabase.instance.client);
  final TaskService _taskService = TaskService(Supabase.instance.client); 
  final CommentService _commentService = CommentService(Supabase.instance.client);

  Future<bool> updateTopicStatus(String workspaceId, String status, String? feedback) async {
    try {
      await _workspaceService.updateTopicStatus(workspaceId, status, feedback);
      return true;
    } catch (e) {
      print("Gagal validasi topik: $e");
      return false;
    }
  }

  Future<bool> updateProject(String joinCode, {String? title, String? description, String? submissionInfo}) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (submissionInfo != null) data['final_submission_info'] = submissionInfo;
      
      await _projectService.updateProject(joinCode, data);
      return true;
    } catch (e) {
      print("Error update project: $e");
      return false;
    }
  }

  Future<bool> closeProject(String joinCode) async {
    try {
      await _projectService.closeProject(joinCode);
      return true;
    } catch (e) {
      print("Error close project: $e");
      return false;
    }
  }
  
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      // Ambil ID dari sesi Supabase, atau pakai ID Dummy jika sedang testing lokal
      final String userId = Supabase.instance.client.auth.currentUser?.id ?? "d05e0001-0000-0000-0000-000000000000";
      return await _userService.getUserProfile(userId);
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  Future<List<ProjectModel>> getAllProjects() async {
    try {
      return await _projectService.getProjects();
    } catch (e) {
      print("DEBUG ERROR: Gagal ambil proyek: $e");
      return [];
    }
  }

  Future<List<WorkspaceModel>> getWorkspacesByJoinCode(String joinCode) async {
    try {
      return await _workspaceService.getWorkspacesByJoinCode(joinCode);
    } catch (e) {
      print("DEBUG ERROR: Gagal ambil kelompok: $e");
      return [];
    }
  }

  Future<List<CommentModel>> getPhaseComments(String phaseId) async {
    try {
      return await _commentService.getCommentsByPhaseId(phaseId);
    } catch (e) {
      print("Error fetching comments: $e");
      return [];
    }
  }

  Future<bool> sendPhaseComment(String phaseId, String text) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? "d05e0001-0000-0000-0000-000000000000";
      final comment = CommentModel(
        id: '', // Diabaikan oleh toJson Supabase
        phaseId: phaseId,
        userId: userId,
        commentText: text,
        clientCreatedAt: DateTime.now(),
      );
      await _commentService.createComment(comment);
      return true;
    } catch (e) {
      print("Error sending comment: $e");
      return false;
    }
  }

  Future<double> getRealWorkspaceProgress(String workspaceId) async {
    try {
      // 1. Ambil semua fase di kelompok ini
      final phases = await _phaseService.getPhases(workspaceId);
      if (phases.isEmpty) return 0.0;

      int totalTasks = 0;
      int doneTasks = 0;

      // 2. Hitung semua tugas di setiap fase
      for (var phase in phases) {
        final tasks = await _taskService.getTasks(phase.id);
        totalTasks += tasks.length;
        // Hitung tugas yang sudah dicentang selesai oleh mahasiswa
        doneTasks += tasks.where((t) => t.isDone).length; 
      }

      // 3. Kalkulasi persentase
      if (totalTasks == 0) return 0.0;
      return doneTasks / totalTasks;

    } catch (e) {
      print("Error hitung progress: $e");
      return 0.0;
    }
  }

  Future<String?> createProject(String title, String description, String? finalInfo) async {
    try {
      final String lecturerId = Supabase.instance.client.auth.currentUser?.id ?? "d05e0001-0000-0000-0000-000000000000";
      final String joinCode = _generateRandomCode();
      
      final newProject = ProjectModel(
        joinCode: joinCode,
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