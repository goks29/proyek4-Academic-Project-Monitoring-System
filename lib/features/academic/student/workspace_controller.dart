import 'package:flutter/material.dart';
import 'package:academic_project_monitoring_system/models/workspace_model.dart';
import 'package:academic_project_monitoring_system/services/remote/workspace_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkspaceController extends ChangeNotifier {
  final WorkspaceService _service = WorkspaceService(Supabase.instance.client);

  List<WorkspaceModel> _myWorkspaces = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<WorkspaceModel> get myWorkspaces => _myWorkspaces;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> createWorkspace({
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
      await fetchMyWorkspaces(onlyLocal: true); 
    } catch (e) {
      _errorMessage = "Gagal membuat kelompok: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMyWorkspaces({bool onlyLocal = false}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _myWorkspaces = await _service.getAllWorkspacesLocal();
      notifyListeners(); 
      if (!onlyLocal) {
        _myWorkspaces = await _service.fetchWorkspacesFromCloud();
      }
    } catch (e) {
      _errorMessage = "Gagal memuat data kelompok.";
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}