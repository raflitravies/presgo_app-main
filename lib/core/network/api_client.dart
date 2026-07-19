import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Map<String, String> _headers({bool withAuth = true, String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: _headers(token: token),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body,
      {bool withAuth = true}) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: _headers(withAuth: withAuth, token: token),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: _headers(token: token),
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw ApiException(
        message: body['message'] ?? 'Something went wrong',
        statusCode: response.statusCode,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => message;
}