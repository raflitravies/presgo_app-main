import '../core/network/api_client.dart';
import '../models/event_model.dart';

class EventService {
  final ApiClient _api = ApiClient();

  Future<List<EventModel>> getEvents() async {
    final response = await _api.get('/events');
    return (response['data'] as List)
        .map((e) => EventModel.fromJson(e))
        .toList();
  }

  Future<EventModel> getEventById(int id) async {
    final response = await _api.get('/events/$id');
    return EventModel.fromJson(response['data']);
  }
}