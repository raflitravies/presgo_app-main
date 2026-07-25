import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _service = ChatService();

  List<ChatRoomModel> _rooms = [];
  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  List<ChatRoomModel> get rooms => _rooms;
  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  Future<void> loadRooms() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rooms = await _service.getMyRooms();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(int roomId) async {
    _isLoading = true;
    _messages = [];
    notifyListeners();

    try {
      _messages = await _service.getMessages(roomId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(int roomId, String content) async {
    _isSending = true;
    notifyListeners();

    try {
      final message = await _service.sendMessage(roomId, content);
      _messages.add(message);

      // Update last message di room list sekaligus mempertahankan unreadCount
      final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
      if (roomIndex != -1) {
        final currentRoom = _rooms[roomIndex];
        _rooms[roomIndex] = ChatRoomModel(
          id: currentRoom.id,
          type: currentRoom.type,
          name: currentRoom.name,
          offeringId: currentRoom.offeringId,
          lastMessage: content,
          lastMessageAt: message.createdAt,
          unreadCount: currentRoom.unreadCount, // Pertahankan nilai unreadCount
        );

        // Geser room yang baru di-chat ke urutan paling atas secara lokal
        final updatedRoom = _rooms.removeAt(roomIndex);
        _rooms.insert(0, updatedRoom);
      }

      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}