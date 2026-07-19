import '../core/network/api_client.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  final ApiClient _api = ApiClient();

  Future<List<ScheduleModel>> getMyClassSchedule() async {
    final response = await _api.get('/schedules/my/class');
    return (response['data'] as List)
        .map((s) => ScheduleModel.fromJson(s))
        .toList();
  }

  Future<List<ScheduleModel>> getMyExamSchedule() async {
    final response = await _api.get('/schedules/my/exam');
    return (response['data'] as List)
        .map((s) => ScheduleModel.fromJson(s))
        .toList();
  }

  Future<List<ScheduleModel>> getMyTeachingSchedule() async {
    final response = await _api.get('/schedules/my/teaching');
    return (response['data'] as List)
        .map((s) => ScheduleModel.fromJson(s))
        .toList();
  }

  Future<List<ScheduleModel>> getMyExamAsLecturer() async {
    final response = await _api.get('/schedules/my/exam/teaching');
    return (response['data'] as List)
        .map((s) => ScheduleModel.fromJson(s))
        .toList();
  }
}