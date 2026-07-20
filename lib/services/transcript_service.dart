import '../core/network/api_client.dart';
import '../models/transcript_model.dart';

class TranscriptService {
  final ApiClient _api = ApiClient();

  Future<TranscriptModel> getMyTranscript() async {
    final response = await _api.get('/grades/my/transcript');
    return TranscriptModel.fromJson(response['data']);
  }
}