import 'package:flutter/material.dart';
import 'package:academic_project_monitoring_system/features/academic/student/model/workspace_model.dart';
import 'workspace_service.dart';

class WorkspaceController extends ChangeNotifier {
  final WorkspaceService _service = WorkspaceService();

  List<WorkspaceModel> _myWorkspaces = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<WorkspaceModel> get myWorkspace => _myWorkspaces;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> createWorkspace ({
    required String projectId,
    required String teamName,
    required String nim,
    String? topic,
    String? description
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _service.createWorkspace(
        projectId: projectId,
        teamName: teamName,
        creatorId: nim,
        topicName: topic,
        topicDescription: description,
      );

      await fetchMyWorkspaces(); 
    } catch (e) {
      _errorMessage = "Gagal membuat kelompok: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMyWorkspaces() async {
    _setLoading(true);
    try {
      _myWorkspaces = await _service.getAllWorkspaces();
      _setLoading(true);
    } catch (e) {
      _errorMessage = "Gagal memuat data kelompok.";
    } finally {
      _setLoading(false);
    }
  }

  // notify UI
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}