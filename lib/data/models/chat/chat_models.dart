// lib/data/models/chat/chat_model.dart

class ChatModel {
  final int id;
  final String? name;
  final bool isGroup;
  final String createdBy;
  final String createdAt;
  final String updatedAt;
  final String? imagePath;
  final List<ChatUserModel> users;

  ChatModel({
    required this.id,
    this.name,
    required this.isGroup,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
    required this.users,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      name: json['name'],
      isGroup: json['is_group'] == 1,
      createdBy: json['created_by'].toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      imagePath: json['image_path'],
      // users: (json['users'] as List)
      //     .map((user) => ChatUserModel.fromJson(user))
      //     .toList(),
      users:
          (json['users'] as List<dynamic>?)
              ?.map((user) => ChatUserModel.fromJson(user))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_group': isGroup ? 1 : 0,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'image_path': imagePath,
      'users': users.map((user) => user.toJson()).toList(),
    };
  }
}

class ChatUserModel {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? emailVerificationToken;
  final String createdAt;
  final String updatedAt;
  final int countryId;
  final int roleId;
  final int activityStatus;
  final ChatPivotModel pivot;

  ChatUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.emailVerificationToken,
    required this.createdAt,
    required this.updatedAt,
    required this.countryId,
    required this.roleId,
    required this.activityStatus,
    required this.pivot,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      emailVerificationToken: json['email_verification_token'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      countryId: json['country_id'],
      roleId: json['role_id'],
      activityStatus: json['activity_status'],
      pivot: ChatPivotModel.fromJson(json['pivot']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'email_verification_token': emailVerificationToken,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'country_id': countryId,
      'role_id': roleId,
      'activity_status': activityStatus,
      'pivot': pivot.toJson(),
    };
  }

  // Helper method to get user initials
  String get initials {
    List<String> parts = name.split(' ');
    String initials = '';

    for (int i = 0; i < parts.length && i < 2; i++) {
      if (parts[i].isNotEmpty) {
        initials += parts[i][0].toUpperCase();
      }
    }

    return initials.isEmpty ? 'U' : initials;
  }

  // Helper method to check if user is online
  bool get isOnline => activityStatus == 1;
}

class ChatPivotModel {
  final int chatId;
  final int userId;
  final String createdAt;
  final String updatedAt;

  ChatPivotModel({
    required this.chatId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatPivotModel.fromJson(Map<String, dynamic> json) {
    return ChatPivotModel(
      chatId: json['chat_id'],
      userId: json['user_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class CreateChatResponse {
  final String message;
  final ChatModel chat;

  CreateChatResponse({required this.message, required this.chat});

  factory CreateChatResponse.fromJson(Map<String, dynamic> json) {
    return CreateChatResponse(
      message: json['message'],
      chat: ChatModel.fromJson(json['chat']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'chat': chat.toJson()};
  }
}
