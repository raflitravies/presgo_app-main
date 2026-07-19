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
      _errorMessage = e.toString();
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
}