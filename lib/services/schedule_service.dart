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

  Future<ScheduleModel> createExamSchedule(int offeringId, String examDate,
      String startTime, String endTime, String? room) async {
    final response = await _api.post('/schedules/exam', {
      'offeringId': offeringId,
      'examDate': examDate,
      'startTime': startTime,
      'endTime': endTime,
      if (room != null) 'room': room,
    });
    return ScheduleModel.fromJson(response['data']);
  }

  // ✅ METHOD RESCHEDULE CLASS
  Future<ScheduleModel> createRescheduleSchedule({
    required int offeringId,
    required String originalDate,
    required String newDate,
    required String startTime,
    required String endTime,
    String? room,
  }) async {
    final response = await _api.post('/schedules/reschedule', {
      'offeringId': offeringId,
      'originalDate': originalDate,
      'newDate': newDate,
      'startTime': startTime,
      'endTime': endTime,
      if (room != null && room.isNotEmpty) 'room': room,
    });
    return ScheduleModel.fromJson(response['data']);
  }

  Future<List<ScheduleModel>> getOfferingSchedules(int offeringId) async {
    final response = await _api.get('/schedules/offering/$offeringId');
    return (response['data'] as List)
        .map((s) => ScheduleModel.fromJson(s))
        .toList();
  }
}