class ChatRoomModel {
  final int id;
  final String type;
  final String name;
  final int? offeringId;
  final String? lastMessage;
  final String? lastMessageAt;
  int unreadCount;

  ChatRoomModel({
    required this.id,
    required this.type,
    required this.name,
    this.offeringId,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      offeringId: json['offeringId'],
      lastMessage: json['lastMessage'],
      lastMessageAt: json['lastMessageAt'],
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}

class ChatMessageModel {
  final int id;
  final int roomId;
  final int senderId;
  final String senderName;
  final String content;
  final String createdAt;

  ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      roomId: json['roomId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      content: json['content'],
      createdAt: json['createdAt'],
    );
  }
}