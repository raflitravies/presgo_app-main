import '../core/network/api_client.dart';
import '../models/evaluation_model.dart';

class EvaluationService {
  final ApiClient _api = ApiClient();

  Future<List<EvaluationCourseModel>> getMyPendingEvaluations() async {
    final response = await _api.get('/evaluations/my/pending');
    return (response['data'] as List)
        .map((e) => EvaluationCourseModel.fromJson(e))
        .toList();
  }

  Future<void> submitEvaluation(
      int offeringId, List<Map<String, dynamic>> responses) async {
    await _api.post('/evaluations/submit', {
      'offeringId': offeringId,
      'responses': responses,
    });
  }
}