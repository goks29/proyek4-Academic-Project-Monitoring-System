import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:academic_project_monitoring_system/models/workspace_model.dart';
import 'package:academic_project_monitoring_system/models/workspace_member_model.dart';
import 'package:academic_project_monitoring_system/services/remote/workspace_service.dart';

/// Controller global (didaftarkan di main.dart) yang hanya mengelola
/// daftar workspace milik user. Operasi detail workspace ada di
/// [WorkspaceDetailController] (scoped per-route).
class WorkspaceController extends ChangeNotifier {
  final WorkspaceService _service =
      WorkspaceService(Supabase.instance.client);
  final Uuid _uuid = const Uuid();

  List<WorkspaceModel> _myWorkspaces = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<WorkspaceModel> get myWorkspaces => _myWorkspaces;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int totalSelesai = 0;
  int totalTertunda = 0;

  Map<String, double> workspaceProgress = {};

  // ── Ambil daftar workspace ─────────────────────────────────────────────────

  Future<void> fetchMyWorkspaces({bool onlyLocal = false}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      if (onlyLocal) {
        _myWorkspaces = await _service.getAllWorkspacesLocal();
      } else {
        _myWorkspaces = await _service.fetchWorkspacesFromCloud();
      }
      
      // Hitung statistik dan progress secara paralel
      final futures = <Future>[];
      futures.add(fetchUserTaskStats(shouldNotify: false));
      for (var ws in _myWorkspaces) {
        futures.add(calculateWorkspaceProgress(ws.id, shouldNotify: false));
      }
      await Future.wait(futures);
    } catch (e) {
      _errorMessage = 'Gagal memuat data kelompok.';
      _myWorkspaces = await _service.getAllWorkspacesLocal();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> calculateWorkspaceProgress(String workspaceId, {bool shouldNotify = true}) async {
    try {
      final tasks = await _service.fetchTasksByWorkspaces(workspaceId);
      
      if (tasks.isEmpty) {
        workspaceProgress[workspaceId] = 0.0;
      } else {
        double totalProgress = tasks.fold(0.0, (sum, task) => sum + task.progress);
        workspaceProgress[workspaceId] = totalProgress / tasks.length;
      }
      if (shouldNotify) notifyListeners();
    } catch (e) {
      workspaceProgress[workspaceId] = 0.0;
    }
  }

  // ── Buat workspace baru ────────────────────────────────────────────────────

  Future<void> createWorkspace({
    required String teamName,
    String? topic,
    String? description,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        _errorMessage = 'User belum login.';
        return;
      }
      await _service.createWorkspace(
        teamName: teamName,
        creatorId: currentUser.id,
        topicName: topic,
        topicDescription: description,
      );
      await fetchMyWorkspaces(onlyLocal: true);
    } catch (e) {
      _errorMessage = 'Gagal membuat kelompok: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // ── Bergabung ke workspace via ID ──────────────────────────────────────────

  Future<bool> joinWorkspaceById(String workspaceId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        _errorMessage = 'User belum login.';
        return false;
      }
      final workspace = await _service.getWorkspaceById(workspaceId);
      if (workspace == null) {
        _errorMessage =
            'Workspace tidak ditemukan. Pastikan ID sudah benar.';
        return false;
      }
      await _service.addMemberToWorkspace(workspaceId, currentUser.id,
          isLeader: false);
      await fetchMyWorkspaces();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal bergabung ke workspace: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Bersihkan data lokal ───────────────────────────────────────────────────

  Future<void> clearLocalData() async {
    _myWorkspaces = [];
    _errorMessage = null;
    try {
      await (await Hive.openBox<WorkspaceModel>('workspaces')).clear();
      await (await Hive.openBox<WorkspaceMemberModel>('workspace_members'))
          .clear();
    } catch (_) {}
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ── Hitung statistik ───────────────────────────────────────────────────
  Future<void> fetchUserTaskStats({bool shouldNotify = true}) async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;
    final response = await Supabase.instance.client
        .from('task_allocations')
        .select('is_done')
        .eq('student_id', currentUser.id);
    
    final tasks = response as List<dynamic>;
    totalSelesai = tasks.where((t) => t['is_done'] == true).length;
    totalTertunda = tasks.where((t) => t['is_done'] == false).length;
    
    if (shouldNotify) notifyListeners();
  }
}