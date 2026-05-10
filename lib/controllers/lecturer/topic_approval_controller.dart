import 'package:flutter/foundation.dart';
import '../../models/workspace_model.dart';
import '../../repositories/workspace_repository.dart';

class TopicApprovalController extends ChangeNotifier {
  final WorkspaceRepository _repository;

  List<WorkspaceModel> workspaces = [];
  bool isLoading = false;
  String? errorMessage;

  TopicApprovalController(this._repository);

  Future<void> fetchWorkspacesByProject(String joinCode) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      workspaces = await _repository.getWorkspacesByJoinCode(joinCode);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveTopic(String workspaceId, String status, String? feedback) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateTopicStatus(workspaceId, status, feedback);

      final index = workspaces.indexWhere((w) => w.id == workspaceId);
      if (index != -1) {
        workspaces[index] = WorkspaceModel(
          id: workspaces[index].id,
          projectId: workspaces[index].projectId,
          joinCode: workspaces[index].joinCode,
          teamName: workspaces[index].teamName,
          topicName: workspaces[index].topicName,
          topicDescription: workspaces[index].topicDescription,
          status: status,
          lecturerFeedback: feedback,
          progressionMode: workspaces[index].progressionMode,
          isCompleted: workspaces[index].isCompleted,
          clientCreatedAt: workspaces[index].clientCreatedAt,
          serverReceivedAt: workspaces[index].serverReceivedAt,
        );
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
