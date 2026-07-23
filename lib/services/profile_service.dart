import '../core/network/api_client.dart';

class ProfileService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> getStudentProfile() async {
    final response = await _api.get('/profiles/student/me');
    return response['data'];
  }

  Future<Map<String, dynamic>> getLecturerProfile() async {
    final response = await _api.get('/profiles/lecturer/me');
    return response['data'];
  }

  Future<Map<String, dynamic>> getStaffProfile() async {
    final response = await _api.get('/profiles/staff/me');
    return response['data'];
  }

  Future<void> updateProfile(String? fullName, String? phone) async {
    await _api.put('/users/me', {
      if (fullName != null) 'fullName': fullName,
      if (phone != null) 'phone': phone,
    });
  }
}