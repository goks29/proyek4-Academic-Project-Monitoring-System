import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:academic_project_monitoring_system/services/auth_service.dart';
import 'package:academic_project_monitoring_system/models/user_model.dart';

class LoginController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isCheckingSession = true;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isCheckingSession => _isCheckingSession;
  String? get error => _error;

  // Cek sesi sudah login atau belum
  Future<void> checkSession() async {
    _isCheckingSession = true;
    notifyListeners();

    try {
      final session = await _authService.getActiveSession();
      if (session != null) {
        _currentUser = await _authService.getLocalProfile();
      }
    } catch (e) {
      _currentUser = null;
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }

  Future<bool> handleLogin(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(email, password);
      return _currentUser != null;
    } catch (e) {
      debugPrint('[LOGIN ERROR] ${e.runtimeType}: $e');
      _error = "Email atau password salah. Silakan coba lagi.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleLogout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _error = null;
    } catch (e) {
      debugPrint('[LOGIN ERROR] ${e.runtimeType}: $e');
      _error = "Anda tidak bisa login/logout ketika sedang offline";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    _currentUser = await _authService.getLocalProfile();
    notifyListeners();
  }
}