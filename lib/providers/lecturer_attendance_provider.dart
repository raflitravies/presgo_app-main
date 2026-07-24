import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/attendance_model.dart';
import '../models/course_offering_model.dart';
import '../services/attendance_service.dart';

class LecturerAttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  final ApiClient _api = ApiClient();

  List<CourseOfferingModel> _offerings = [];
  List<AttendanceSessionModel> _sessions = [];
  List<AttendanceRecordModel> _records = [];
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;

  List<CourseOfferingModel> get offerings => _offerings;
  List<AttendanceSessionModel> get sessions => _sessions;
  List<AttendanceRecordModel> get records => _records;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;

  Future<void> loadMyOfferings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get('/courses/offerings/my-teaching');
      _offerings = (response['data'] as List)
          .map((o) => CourseOfferingModel.fromJson(o))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSessionsByOffering(int offeringId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _sessions = await _attendanceService.getSessionsByOffering(offeringId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecordsBySession(int sessionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _records = await _attendanceService.getRecordsBySession(sessionId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSession(int offeringId, String sessionDate,
      int weekNumber, String? topic) async {
    _isCreating = true;
    notifyListeners();

    try {
      final session = await _attendanceService.createSession(
          offeringId, sessionDate, weekNumber, topic);
      _sessions.insert(0, session);
      _isCreating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isCreating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> closeSession(int sessionId) async {
    try {
      final updated = await _attendanceService.closeSession(sessionId);
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) _sessions[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAttendanceManual(
      int sessionId, int studentId, String status, String? note) async {
    try {
      final response = await _api.put(
        '/attendance/sessions/$sessionId/manual',
        {
          'studentId': studentId,
          'status': status,
          if (note != null) 'note': note,
        },
      );
      // Refresh records
      await loadRecordsBySession(sessionId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearRecords() {
    _records = [];
    notifyListeners();
  }
}