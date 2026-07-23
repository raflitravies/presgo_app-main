import '../core/network/api_client.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  final ApiClient _api = ApiClient();

  Future<List<AnnouncementModel>> getAnnouncements() async {
    final response = await _api.get('/announcements');
    return (response['data'] as List)
        .map((a) => AnnouncementModel.fromJson(a))
        .toList();
  }

  Future<AnnouncementModel> getAnnouncementById(int id) async {
    final response = await _api.get('/announcements/$id');
    return AnnouncementModel.fromJson(response['data']);
  }
}