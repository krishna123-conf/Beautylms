class ChatMessage {
  final String sender;
  final String message;
  final String timestamp;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: json['sender'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
