import '../core/network/api_client.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final ApiClient _api = ApiClient();

  // Student
  Future<List<AttendanceSummaryModel>> getMySummary() async {
    final response = await _api.get('/attendance/my/summary');
    return (response['data'] as List)
        .map((s) => AttendanceSummaryModel.fromJson(s))
        .toList();
  }

  Future<List<AttendanceRecordModel>> getMyRecordsByOffering(int offeringId) async {
    final response = await _api.get('/attendance/my/offering/$offeringId');
    return (response['data'] as List)
        .map((r) => AttendanceRecordModel.fromJson(r))
        .toList();
  }

  // 💡 DIFIX: Mengembalikan List<AttendanceSessionModel> untuk kebutuhan dropdown sesi aktif
  Future<List<AttendanceSessionModel>> getActiveSessionsByOffering(int offeringId) async {
    try {
      final response = await _api.get('/attendance/offering/$offeringId/active');
      if (response['data'] != null) {
        return (response['data'] as List)
            .map((s) => AttendanceSessionModel.fromJson(s))
            .toList();
      }
    } catch (e) {
      // Jika 400/404 atau tidak ada sesi BUKA (isOpen = true)
      return [];
    }
    return [];
  }

  Future<AttendanceRecordModel> checkInWithPin(int sessionId, String pin) async {
    final response = await _api.post('/attendance/check-in/pin', {
      'sessionId': sessionId,
      'pin': pin,
    });
    return AttendanceRecordModel.fromJson(response['data']);
  }

  Future<AttendanceRecordModel> checkInWithQr(String qrToken) async {
    final response = await _api.post('/attendance/check-in/qr', {
      'qrToken': qrToken,
    });
    return AttendanceRecordModel.fromJson(response['data']);
  }

  // Lecturer
  Future<List<AttendanceSessionModel>> getSessionsByOffering(int offeringId) async {
    final response = await _api.get('/attendance/sessions/offering/$offeringId');
    return (response['data'] as List)
        .map((s) => AttendanceSessionModel.fromJson(s))
        .toList();
  }

  Future<AttendanceSessionModel> createSession(
      int offeringId, String sessionDate, int weekNumber, String? topic) async {
    final response = await _api.post('/attendance/sessions', {
      'offeringId': offeringId,
      'sessionDate': sessionDate,
      'weekNumber': weekNumber,
      if (topic != null) 'topic': topic,
    });
    return AttendanceSessionModel.fromJson(response['data']);
  }

  Future<AttendanceSessionModel> closeSession(int sessionId) async {
    final response = await _api.put('/attendance/sessions/$sessionId/close', {});
    return AttendanceSessionModel.fromJson(response['data']);
  }

  Future<List<AttendanceRecordModel>> getRecordsBySession(int sessionId) async {
    final response = await _api.get('/attendance/sessions/$sessionId/records');
    return (response['data'] as List)
        .map((r) => AttendanceRecordModel.fromJson(r))
        .toList();
  }

  Future<List<dynamic>> getMyTeachingOfferings() async {
    final response = await _api.get('/courses/offerings/my-teaching');
    return response['data'] as List;
  }
}