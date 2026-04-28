import 'package:academic_project_monitoring_system/models/task_allocation_model.dart';
import 'package:academic_project_monitoring_system/models/user_model.dart';
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

  Future<String> createWorkspace({
    required String projectId,
    required String teamName,
    required String creatorId,
    String? topicName,
    String? topicDescription,
    DateTime? serverReceivedAt
  }) async {
    final workspaceId = _uuid.v4();
    
    // Objek Model
    final newWorkspace = WorkspaceModel(
      id: workspaceId,
      projectId: projectId,
      teamName: teamName,
      topicName: topicName,
      topicDescription: topicDescription,
      progressionMode: 'strict', // Default value
      isCompleted: false,
      clientCreatedAt: DateTime.now(),
      serverReceivedAt: null, //belum sinkron
    );

    // Hive
    var box = await Hive.openBox<WorkspaceModel>(_workspaceBoxName);
    await box.put(workspaceId, newWorkspace);

    // Otomatis jadi ketua kelompok
    await addMemberToWorkspace(workspaceId, creatorId, isLeader: true);

    try {
      await _supabaseClient.from('workspaces').insert(newWorkspace.toJson());
      newWorkspace.serverReceivedAt = DateTime.now();
      await newWorkspace.save();
    } catch (e) {
      newWorkspace.serverReceivedAt = null;
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
    try {
      final response = await _supabaseClient.from('workspaces').select();
      final cloudData = (response as List<dynamic>)
          .map((json) => WorkspaceModel.fromJson(json))
          .toList();
      var box = await Hive.openBox<WorkspaceModel>(_workspaceBoxName);
      for (var ws in cloudData) {
        await box.put(ws.id, ws);
      }
      return cloudData;
    } catch (e) {
      return await getAllWorkspacesLocal();
    }
  }

  Future<void> addMemberToWorkspace(
    String workspaceId, 
    String studentId, 
    {bool isLeader = false}
  ) async {
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
      // Simpan log untuk sinkronisasi nanti
    }
  }

  // Update topik proyek dalam workspace
  /// Memperbarui judul topik proyek di dalam sebuah workspace.
  Future<void> updateTopic(String workspaceId, String newTopic) async {
    await _supabaseClient
        .from('workspaces')
        .update({'topic_name': newTopic})
        .eq('id', workspaceId);
  }

  Future<List<TaskAllocationModel>> fetchTasksByWorkspaces(String workspaceId) async{
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

  Future<List<UserModel>> fetchWorkspacesMember(String workspaceId) async {
    try {
      final response = await _supabaseClient
        .from('workspace_members')
        .select('*, users!inner(*)')
        .eq('workspace_id', workspaceId);

      final members = (response as List).map((data) {
        return UserModel.fromJson(data['users']);
      }).toList();
      var box = Hive.box<UserModel>('workspace_members');
      for (var member in members) {
        await box.put(member.id, member);
      }

      return members;
    } catch (e) {
      var box = Hive.box<UserModel>('workspace_members');
      return box.values.toList();
    }
  }
}