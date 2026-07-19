import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  Future<UserModel> login(String nimNip, String password) async {
    final response = await _api.post(
      '/auth/login',
      {'nimNip': nimNip, 'password': password},
      withAuth: false,
    );

    final data = response['data'];
    final prefs = await SharedPreferences.getInstance();

    // Simpan token
    await prefs.setString(AppConstants.tokenKey, data['token']);
    await prefs.setString(AppConstants.refreshTokenKey, data['refreshToken']);
    await prefs.setString(AppConstants.userKey, jsonEncode(data));

    return UserModel.fromJson(data);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.userKey);
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(AppConstants.userKey);
    if (userStr == null) return null;
    return UserModel.fromJson(jsonDecode(userStr));
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(AppConstants.tokenKey);
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _api.post('/auth/change-password', {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }

  Future<void> updateFirstLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(AppConstants.userKey);
    if (userStr == null) return;

    final userData = jsonDecode(userStr) as Map<String, dynamic>;
    userData['firstLogin'] = false;
    await prefs.setString(AppConstants.userKey, jsonEncode(userData));
  }
}