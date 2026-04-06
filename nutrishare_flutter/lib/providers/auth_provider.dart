import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(email, password);

    _isLoading = false;
    if (result['success']) {
      _user = result['user'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String username,
    String email,
    String password,
    String name,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(username, email, password, name);

    _isLoading = false;
    if (result['success']) {
      _user = result['user'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    return _authService.updateProfile(data);
  }

  /// Register + update profile dalam satu operasi.
  /// `notifyListeners` (→ redirect ke home) baru dipanggil setelah
  /// profile selesai diupdate, bukan langsung setelah register.
  Future<bool> registerWithProfile({
    required String username,
    required String email,
    required String password,
    required Map<String, dynamic> profileData,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 1. Register
    final result = await _authService.register(username, email, password, username);

    if (!result['success']) {
      _isLoading = false;
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }

    // 2. Update profile (token sudah tersimpan dari step register)
    await _authService.updateProfile(profileData);

    // 3. Selesai — tidak auto-login, biarkan user login manual
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> checkLoginStatus() async {
    final data = await _authService.getProfile();
    if (data != null) {
      _user = User.fromJson(data);
    } else {
      _user = null;
    }
    notifyListeners();
  }
}
