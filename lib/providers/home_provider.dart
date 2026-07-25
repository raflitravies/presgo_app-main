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
        _loadTodaySchedule(),
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
      _transcript = TranscriptModel.fromJson(response['data']);
    } catch (e) {
      _transcript = null;
    }
  }

  Future<void> _loadTodaySchedule() async {
    try {
      // ✅ GANTI DARI '/schedules/my/today' JADI '/schedules/my/class'
      final response = await _api.get('/schedules/my/class');
      _todaySchedule = (response['data'] as List)
          .map((s) => ScheduleModel.fromJson(s))
          .toList();
    } catch (e) {
      _todaySchedule = [];
    }
  }

  Future<void> loadLecturerHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ✅ UNTUK DOSEN JUGA GANTI KE '/schedules/my/teaching'
      final response = await _api.get('/schedules/my/teaching');
      _todaySchedule = (response['data'] as List)
          .map((s) => ScheduleModel.fromJson(s))
          .toList();
    } catch (e) {
      _todaySchedule = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}