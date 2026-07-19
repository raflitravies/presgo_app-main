import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final ScheduleService _service = ScheduleService();

  List<ScheduleModel> _classSchedule = [];
  List<ScheduleModel> _examSchedule = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ScheduleModel> get classSchedule => _classSchedule;
  List<ScheduleModel> get examSchedule => _examSchedule;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadStudentSchedule() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getMyClassSchedule(),
        _service.getMyExamSchedule(),
      ]);
      _classSchedule = results[0];
      _examSchedule = results[1];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLecturerSchedule() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getMyTeachingSchedule(),
        _service.getMyExamAsLecturer(),
      ]);
      _classSchedule = results[0];
      _examSchedule = results[1];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}