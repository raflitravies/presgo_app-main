import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/schedule_model.dart';
import '../models/transcript_model.dart';

class HomeProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  TranscriptModel? _transcript;
  List<ScheduleModel> _todaySchedule = [];
  bool _isLoading = false;
  String? _errorMessage;

  TranscriptModel? get transcript => _transcript;
  List<ScheduleModel> get todaySchedule => _todaySchedule;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadTranscript(),
        _loadStudentSchedules(),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadTranscript() async {
    try {
      final response = await _api.get('/grades/my/transcript');
      if (response['data'] != null) {
        _transcript = TranscriptModel.fromJson(response['data']);
      }
    } catch (e) {
      _transcript = null;
    }
  }

  // ✅ UNTUK MAHASISWA: AMBIL SEMUA JADWAL MINGGUAN & RESCHEDULE
  Future<void> _loadStudentSchedules() async {
    try {
      final response = await _api.get('/schedules/my/class');
      if (response['data'] != null) {
        _todaySchedule = (response['data'] as List)
            .map((s) => ScheduleModel.fromJson(s as Map<String, dynamic>))
            .toList();
      } else {
        _todaySchedule = [];
      }
    } catch (e) {
      _todaySchedule = [];
    }
  }

  // ✅ UNTUK DOSEN: AMBIL SEMUA JADWAL MENGAJAR & RESCHEDULE
  Future<void> loadLecturerHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get('/schedules/my/teaching');
      if (response['data'] != null) {
        _todaySchedule = (response['data'] as List)
            .map((s) => ScheduleModel.fromJson(s as Map<String, dynamic>))
            .toList();
      } else {
        _todaySchedule = [];
      }
    } catch (e) {
      _errorMessage = e.toString();
      _todaySchedule = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}