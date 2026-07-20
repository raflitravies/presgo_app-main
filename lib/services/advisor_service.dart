import '../core/network/api_client.dart';
import '../models/advisor_model.dart';

class AdvisorService {
  final ApiClient _api = ApiClient();

  Future<AdvisorAssignmentModel> getMyAdvisor() async {
    final response = await _api.get('/advisor/my');
    return AdvisorAssignmentModel.fromJson(response['data']);
  }

  Future<List<AppointmentModel>> getMyAppointments() async {
    final response = await _api.get('/advisor/appointments/my');
    return (response['data'] as List)
        .map((a) => AppointmentModel.fromJson(a))
        .toList();
  }

  Future<AppointmentModel> createAppointment(
      String scheduledAt, String topic) async {
    final response = await _api.post('/advisor/appointments', {
      'scheduledAt': scheduledAt,
      'topic': topic,
    });
    return AppointmentModel.fromJson(response['data']);
  }
}