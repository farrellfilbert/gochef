class MessageModel {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}

class ChatModel {
  final String id;
  final String otherParticipantName;
  final String otherParticipantAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  ChatModel({
    required this.id,
    required this.otherParticipantName,
    required this.otherParticipantAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    this.isOnline = false,
  });
}
