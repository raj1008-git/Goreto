class Message {
  final int id;
  final int chatId;
  final int sentBy;
  final String messages;
  final DateTime sentAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.chatId,
    required this.sentBy,
    required this.messages,
    required this.sentAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatId: json['chat_id'],
      sentBy: json['sent_by'],
      messages: json['messages'],
      sentAt: DateTime.parse(json['sent_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
