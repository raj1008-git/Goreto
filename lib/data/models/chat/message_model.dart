class Message {
  final int id;
  final String message;
  final int sentBy;
  final DateTime sentAt;

  Message({
    required this.id,
    required this.message,
    required this.sentBy,
    required this.sentAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    message:
        json['messages'], // <-- your backend uses 'messages' key for message text
    sentBy: json['sent_by'],
    sentAt: DateTime.parse(json['sent_at']),
  );
}
