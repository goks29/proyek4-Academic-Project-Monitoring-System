import 'package:flutter/material.dart';
import 'package:academic_project_monitoring_system/services/auth_service.dart';
import 'package:academic_project_monitoring_system/models/user_model.dart';

class LoginController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Future<bool> handleLogin(String email, String password) async {
  //   _isLoading = true;
  //   _error = null;
  //   notifyListeners();

  //   try {
  //     _currentUser = await _authService.login(email, password);
  //     return _currentUser != null;
  //   } catch (e) {
  //     debugPrint("Error: $e");
  //     _error = "Login Gagal: Pastikan email dan password benar.";
  //     return false;
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<bool> handleLogin(String email, String password) async {
    debugPrint("🎬 [Controller] Memulai proses handleLogin...");
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint("📡 [Controller] Memanggil _authService.login...");
      _currentUser = await _authService.login(email, password);
      
      debugPrint("🏁 [Controller] Hasil login: ${_currentUser != null ? 'SUKSES' : 'GAGAL'}");
      return _currentUser != null;
    } catch (e) {
      // Log error ini biasanya yang paling informatif soal Firewall/Koneksi
      debugPrint("💥 [Controller] TERJADI EXCEPTION: $e");
      _error = "Login Gagal: Pastikan email dan password benar.";
      return false;
    } finally {
      _isLoading = false;
      debugPrint("🔄 [Controller] Loading selesai, notifyListeners dipanggil.");
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    _currentUser = await _authService.getLocalProfile();
    notifyListeners();
  }
}