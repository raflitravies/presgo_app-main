import '../core/network/api_client.dart';
import '../models/chat_model.dart';

class ChatService {
  final ApiClient _api = ApiClient();

  Future<List<ChatRoomModel>> getMyRooms() async {
    final response = await _api.get('/chat/rooms');
    return (response['data'] as List)
        .map((r) => ChatRoomModel.fromJson(r))
        .toList();
  }

  Future<List<ChatMessageModel>> getMessages(int roomId) async {
    final response = await _api.get('/chat/rooms/$roomId/messages');
    return (response['data'] as List)
        .map((m) => ChatMessageModel.fromJson(m))
        .toList();
  }

  Future<ChatMessageModel> sendMessage(int roomId, String content) async {
    final response = await _api.post(
      '/chat/rooms/$roomId/messages',
      {'content': content},
    );
    return ChatMessageModel.fromJson(response['data']);
  }
}