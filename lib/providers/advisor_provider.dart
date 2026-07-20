import 'package:flutter/material.dart';
import '../models/advisor_model.dart';
import '../services/advisor_service.dart';

class AdvisorProvider extends ChangeNotifier {
  final AdvisorService _service = AdvisorService();

  AdvisorAssignmentModel? _advisor;
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;

  AdvisorAssignmentModel? get advisor => _advisor;
  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;

  Future<void> loadAdvisorData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getMyAdvisor(),
        _service.getMyAppointments(),
      ]);
      _advisor = results[0] as AdvisorAssignmentModel;
      _appointments = results[1] as List<AppointmentModel>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAppointment(String scheduledAt, String topic) async {
    _isCreating = true;
    notifyListeners();

    try {
      final appointment = await _service.createAppointment(scheduledAt, topic);
      _appointments.insert(0, appointment);
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
}