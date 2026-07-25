import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  bool get isStudent => _user?.role == 'STUDENT';
  bool get isLecturer => _user?.role == 'LECTURER';
  bool get isStaff => _user?.role == 'STAFF';
  bool get isAdmin => _user?.role == 'ADMIN';

  Future<void> checkLoginStatus() async {
    _user = await _authService.getCurrentUser();
    notifyListeners();
  }

  Future<bool> login(String nimNip, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.login(nimNip, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 💡 TAMBAHKAN METHOD INI FOR CHANGE PASSWORD
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _authService.changePassword(oldPassword, newPassword);

      // Update state user lokal (termasuk isFirstLogin = false)
      if (updatedUser != null) {
        _user = updatedUser;
      } else if (_user != null) {
        // Fallback jika backend mengembalikan void/null
        _user = _user!.copyWith(isFirstLogin: false);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  String _cleanErrorMessage(String e) {
    if (e.startsWith('Exception: ')) {
      return e.replaceFirst('Exception: ', '');
    }
    return e;
  }

}