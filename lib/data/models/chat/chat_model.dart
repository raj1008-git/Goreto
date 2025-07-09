class ChatUser {
  final int id;
  final String name;
  final String email;

  ChatUser({required this.id, required this.name, required this.email});

  factory ChatUser.fromJson(Map<String, dynamic> json) =>
      ChatUser(id: json['id'], name: json['name'], email: json['email']);
}

class Chat {
  final int id;
  final bool isGroup;
  final int createdBy;
  final List<ChatUser> users;

  Chat({
    required this.id,
    required this.isGroup,
    required this.createdBy,
    required this.users,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    id: json['id'],
    // Convert int (0/1) or bool to bool safely
    isGroup: json['is_group'] == true || json['is_group'] == 1,
    createdBy: json['created_by'] is int
        ? json['created_by']
        : int.parse(json['created_by'].toString()),
    users: List<ChatUser>.from(json['users'].map((x) => ChatUser.fromJson(x))),
  );
}
