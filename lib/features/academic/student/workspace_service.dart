import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:academic_project_monitoring_system/features/academic/student/model/workspace_member_model.dart';
import 'package:academic_project_monitoring_system/features/academic/student/model/workspace_model.dart';

class WorkspaceService {
  final String _workspaceBoxName = 'workspaces';
  final String _memberBoxName = 'workspace_members';
  final Uuid _uuid = const Uuid();

  Future<String> createWorkspace ({
    required String projectId,
    required String teamName,
    required String creatorId,
    String? topicName,
    String? topicDescription,
  }) async {
    var box = await Hive.openBox<WorkspaceModel>(_workspaceBoxName);
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
      serverReceivedAt: DateTime.now()
    );

    await box.put(workspaceId, newWorkspace);
    
    await addMemberToWorkspace(workspaceId, creatorId, isLeader: true);
    return workspaceId;
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

    // 1 Mahasiswa gabisa masuk di workspaces yang sama lebih dari sekali
    await box.put('${workspaceId}_${studentId}', member);
  }

  Future<List<WorkspaceModel>> getAllWorkspaces() async {
    var box = await Hive.openBox<WorkspaceModel>(_workspaceBoxName);
    List<WorkspaceModel> results = box.values.toList();
    results.sort((a, b) => b.clientCreatedAt.compareTo(a.clientCreatedAt));
    return results;
  }
}