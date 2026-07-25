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
    await _saveAuthData(data);

    return UserModel.fromJson(data);
  }

  Future<UserModel> changePassword(String oldPassword, String newPassword) async {
    final response = await _api.post('/auth/change-password', {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });

    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(AppConstants.userKey);

    Map<String, dynamic> userData = {};

    if (userStr != null) {
      userData = jsonDecode(userStr) as Map<String, dynamic>;
    }

    // Jika backend mengirimkan Map data baru, gunakan data tersebut
    if (response != null && response['data'] != null && response['data'] is Map<String, dynamic>) {
      userData = Map<String, dynamic>.from(response['data'] as Map);
    }

    // Paksa update status first login di Map lokal
    userData['isFirstLogin'] = false;
    userData['firstLogin'] = false;

    // Simpan data user & token baru jika ada
    await _saveAuthData(userData);

    return UserModel.fromJson(userData);
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

  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    if (data['token'] != null) {
      await prefs.setString(AppConstants.tokenKey, data['token'].toString());
    }
    if (data['refreshToken'] != null) {
      await prefs.setString(AppConstants.refreshTokenKey, data['refreshToken'].toString());
    }

    await prefs.setString(AppConstants.userKey, jsonEncode(data));
  }
}