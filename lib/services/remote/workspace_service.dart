import 'package:academic_project_monitoring_system/models/task_allocation_model.dart';
import 'package:academic_project_monitoring_system/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:academic_project_monitoring_system/models/workspace_model.dart';
import 'package:academic_project_monitoring_system/models/workspace_member_model.dart';

class WorkspaceService {
  final SupabaseClient _supabaseClient;
  final String _workspaceBoxName = 'workspaces';
  final String _memberBoxName = 'workspace_members';
  final Uuid _uuid = const Uuid();

  WorkspaceService(this._supabaseClient);

  /// Buat WORKSPACE
  Future<String> createWorkspace({
    String projectId = '',
    required String teamName,
    required String creatorId,
    String? topicName,
    String? topicDescription,
  }) async {
    final workspaceId = _uuid.v4();

    final newWorkspace = WorkspaceModel(
      id: workspaceId,
      projectId: projectId,
      teamName: teamName,
      topicName: topicName,
      topicDescription: topicDescription,
      progressionMode: 'strict',
      isCompleted: false,
      clientCreatedAt: DateTime.now(),
      serverReceivedAt: null,
    );

    var box = await Hive.openBox<WorkspaceModel>(_workspaceBoxName);
    await box.put(workspaceId, newWorkspace);
    try {
      await _supabaseClient.from('workspaces').insert(newWorkspace.toJson());
      newWorkspace.serverReceivedAt = DateTime.now();
      await newWorkspace.save();
      await addMemberToWorkspace(workspaceId, creatorId, isLeader: true);
    } catch (e) {
      newWorkspace.serverReceivedAt = null;
      await newWorkspace.save();
      rethrow;
    }

    return workspaceId;
  }

  Future<List<WorkspaceModel>> getAllWorkspacesLocal() async {
    var box = await Hive.openBox<WorkspaceModel>(_workspaceBoxName);
    List<WorkspaceModel> results = box.values.toList();
    results.sort((a, b) => b.clientCreatedAt.compareTo(a.clientCreatedAt));
    return results;
  }

  Future<List<WorkspaceModel>> fetchWorkspacesFromCloud() async {
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) return [];

    var box = await Hive.openBox<WorkspaceModel>(_workspaceBoxName);

    try {
      final memberResponse = await _supabaseClient
          .from('workspace_members')
          .select('workspace_id')
          .eq('student_id', currentUser.id);

      final List<String> workspaceIds = (memberResponse as List)
          .map((row) => row['workspace_id'] as String)
          .toList();

      if (workspaceIds.isEmpty) return [];

      final response = await _supabaseClient
          .from('workspaces')
          .select('*, projects(title)')
          .inFilter('id', workspaceIds);

      final cloudData = (response as List<dynamic>)
          .map((json) => WorkspaceModel.fromJson(json))
          .toList();
      await box.clear();
      for (var ws in cloudData) {
        await box.put(ws.id, ws);
      }

      return cloudData;
    } catch (e) {
      debugPrint('ERROR FETCH WORKSPACE: $e');
      return box.values.toList();
    }
  }

  /// Mencari WORKSPACE berdasarkan ID
  Future<WorkspaceModel?> getWorkspaceById(String workspaceId) async {
    try {
      final response = await _supabaseClient
          .from('workspaces')
          .select('*, projects(title)') // <--- Tambah JOIN sekalian agar dapet nama project
          .eq('id', workspaceId)
          .maybeSingle();

      if (response == null) {
        debugPrint('getWorkspaceById: response is null (RLS?)');
        return null;
      }
      return WorkspaceModel.fromJson(response);
    } catch (e) {
      debugPrint('getWorkspaceById ERROR: $e');
      return null;
    }
  }

  /// Tambah MEMBER
  Future<void> addMemberToWorkspace(
    String workspaceId,
    String studentId, {
    bool isLeader = false,
  }) async {
    var box = await Hive.openBox<WorkspaceMemberModel>(_memberBoxName);
    final memberId = _uuid.v4();

    final member = WorkspaceMemberModel(
      id: memberId,
      workspaceId: workspaceId,
      studentId: studentId,
      isLeader: isLeader,
    );

    await box.put('${workspaceId}_${studentId}', member);

    try {
      await _supabaseClient.from('workspace_members').insert(member.toJson());
    } catch (e) {
      debugPrint('[addMemberToWorkspace ERROR] $e');
      rethrow;
    }
  }

  /// Ambil Data WORKSPACES MEMBER
  Future<List<UserModel>> fetchWorkspacesMember(String workspaceId) async {
    try {
      final response = await _supabaseClient
          .from('workspace_members')
          .select('*, users!workspace_members_student_id_fkey(*)')
          .eq('workspace_id', workspaceId);

      final members = (response as List)
          .where((data) => data['users'] != null)
          .map((data) {
        return UserModel.fromJson(data['users']);
      }).toList();
      var box = await Hive.openBox<UserModel>('workspace_members_users');
      for (var member in members) {
        await box.put(member.id, member);
      }

      return members;
    } catch (e) {
      debugPrint('[fetchWorkspacesMember ERROR] $e');
      return [];
    }
  }

  /// Cek USER LOGIN apakah ketua workspaces tertentu
  Future<bool> checkIsLeader(String workspaceId) async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) return false;

      final response = await _supabaseClient
          .from('workspace_members')
          .select('is_leader')
          .eq('workspace_id', workspaceId)
          .eq('student_id', currentUser.id)
          .maybeSingle();

      if (response == null) return false;
      return response['is_leader'] as bool? ?? false;
    } catch (e) {
      debugPrint('[checkIsLeader ERROR] $e');
      return false;
    }
  }

  /// Mengajukan TOPIC
  Future<void> updateTopic(
    String workspaceId,
    String topicName, {
    String? topicDescription,
  }) async {
    final Map<String, dynamic> updateData = {'topic_name': topicName};
    if (topicDescription != null) {
      updateData['topic_description'] = topicDescription;
    }

    await _supabaseClient
        .from('workspaces')
        .update(updateData)
        .eq('id', workspaceId);

    var box = await Hive.openBox<WorkspaceModel>(_workspaceBoxName);
    final localWs = box.get(workspaceId);
    if (localWs != null) {
      localWs.topicName = topicName;
      if (topicDescription != null) localWs.topicDescription = topicDescription;
      await localWs.save();
    }
  }

  Future<List<WorkspaceModel>> getWorkspaces() async {
    final response = await _supabaseClient.from('workspaces').select();
    return (response as List<dynamic>)
        .map((json) => WorkspaceModel.fromJson(json))
        .toList();
  }

  Future<List<WorkspaceModel>> getWorkspacesByJoinCode(String joinCode) async {
    final response = await _supabaseClient
        .from('workspaces')
        .select()
        .eq('join_code', joinCode);
    return (response as List<dynamic>)
        .map((json) => WorkspaceModel.fromJson(json))
        .toList();
  }

  Future<WorkspaceModel> createWorkspaceModel(WorkspaceModel workspace) async {
    final response = await _supabaseClient
        .from('workspaces')
        .insert(workspace.toJson())
        .select()
        .single();
    return WorkspaceModel.fromJson(response);
  }

  Future<void> joinProject(String workspaceId, String joinCode) async {
    await _supabaseClient
        .from('workspaces')
        .update({'join_code': joinCode})
        .eq('id', workspaceId);
  }

  Future<void> updateWorkspace(String workspaceId, Map<String, dynamic> data) async {
    await _supabaseClient
        .from('workspaces')
        .update(data)
        .eq('id', workspaceId);
  }

  Future<void> updateTopicStatus(String workspaceId, String status, String? feedback) async {
    await _supabaseClient
        .from('workspaces')
        .update({
          'status': status,
          'lecturer_feedback': feedback,
        })
        .eq('id', workspaceId);
  }

  /// Menghubungkan WORKSPACES ke PROJECT dosen via join_code.
  Future<void> linkWorkspaceToProject(
    String workspaceId,
    String projectId,
  ) async {
    final response = await _supabaseClient
        .from('workspaces')
        .update({'project_id': projectId})
        .eq('id', workspaceId)
        .select();
        
    if ((response as List).isEmpty) {
      throw Exception('Update gagal (kemungkinan Row-Level Security menolak akses)');
    }
    var box = await Hive.openBox<WorkspaceModel>(_workspaceBoxName);
    final localWs = box.get(workspaceId);
    if (localWs != null) {
      localWs.projectId = projectId;
      await localWs.save();
    }
  }

  /// Ambil semua TASK ALLOCATION
  Future<List<TaskAllocationModel>> fetchTasksByWorkspaces(String workspaceId) async {
    try {
      final response = await _supabaseClient
          .from('task_allocations')
          .select('*, progress_phases!inner(workspace_id)')
          .eq('progress_phases.workspace_id', workspaceId);

      return (response as List)
          .map((json) => TaskAllocationModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}