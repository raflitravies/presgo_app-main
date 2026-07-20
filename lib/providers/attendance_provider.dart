import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _service = AttendanceService();

  List<AttendanceSummaryModel> _summary = [];
  List<AttendanceRecordModel> _records = [];
  bool _isLoading = false;
  bool _isChecking = false;
  String? _errorMessage;
  String? _successMessage;

  List<AttendanceSummaryModel> get summary => _summary;
  List<AttendanceRecordModel> get records => _records;
  bool get isLoading => _isLoading;
  bool get isChecking => _isChecking;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> loadMySummary() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await _service.getMySummary();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyRecordsByOffering(int offeringId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _records = await _service.getMyRecordsByOffering(offeringId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkInWithPin(int sessionId, String pin) async {
    _isChecking = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.checkInWithPin(sessionId, pin);
      _successMessage = 'Check-in successful!';
      _isChecking = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isChecking = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkInWithQr(String qrToken) async {
    _isChecking = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.checkInWithQr(qrToken);
      _successMessage = 'Check-in successful!';
      _isChecking = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isChecking = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  List<AttendanceSessionModel> _sessions = [];
  List<AttendanceSessionModel> get sessions => _sessions;

  Future<void> loadSessionsByOffering(int offeringId) async {
    try {
      _sessions = await _service.getSessionsByOffering(offeringId);
      notifyListeners();
    } catch (e) {
      _sessions = [];
      notifyListeners();
    }
  }
}