import 'package:flutter/foundation.dart';

class ChatCreationResponse {
  final String message;
  final Chat chat;

  ChatCreationResponse({required this.message, required this.chat});

  factory ChatCreationResponse.fromJson(Map<String, dynamic> json) {
    if (json['message'] == null) {
      debugPrint(
        "ChatCreationResponse: 'message' field is null or missing in JSON: $json",
      );
      throw const FormatException(
        "ChatCreationResponse: 'message' field is null or missing.",
      );
    }
    if (json['chat'] == null) {
      debugPrint(
        "ChatCreationResponse: 'chat' field is null or missing in JSON: $json",
      );
      throw const FormatException(
        "ChatCreationResponse: 'chat' field is null or missing.",
      );
    }

    return ChatCreationResponse(
      message: json['message'] as String,
      chat: Chat.fromJson(json['chat'] as Map<String, dynamic>),
    );
  }
}

class Chat {
  final int id;
  final String? name;
  final int isGroup;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imagePath;
  final List<ChatUser> users;

  Chat({
    required this.id,
    this.name,
    required this.isGroup,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
    required this.users,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      debugPrint("Chat: 'id' field is null or missing in JSON: $json");
      throw const FormatException("Chat: 'id' field is null or missing.");
    }
    if (json['is_group'] == null) {
      debugPrint("Chat: 'is_group' field is null or missing in JSON: $json");
      throw const FormatException("Chat: 'is_group' field is null or missing.");
    }
    if (json['created_by'] == null) {
      debugPrint("Chat: 'created_by' field is null or missing in JSON: $json");
      throw const FormatException(
        "Chat: 'created_by' field is null or missing.",
      );
    }
    if (json['created_at'] == null) {
      debugPrint("Chat: 'created_at' field is null or missing in JSON: $json");
      throw const FormatException(
        "Chat: 'created_at' field is null or missing.",
      );
    }
    if (json['updated_at'] == null) {
      debugPrint("Chat: 'updated_at' field is null or missing in JSON: $json");
      throw const FormatException(
        "Chat: 'updated_at' field is null or missing.",
      );
    }

    final dynamic usersData = json['users'];

    List<ChatUser> parsedUsers = [];
    if (usersData == null) {
      debugPrint(
        "Chat.fromJson: 'users' field is null in JSON: $json. Initializing with empty list.",
      );
    } else if (usersData is List) {
      parsedUsers = usersData.map((userJson) {
        if (userJson == null) {
          debugPrint("Chat.fromJson: Null item found in 'users' list: $json");
          throw const FormatException(
            "Chat.fromJson: Null item found in 'users' list.",
          );
        }
        return ChatUser.fromJson(userJson as Map<String, dynamic>);
      }).toList();
    } else {
      debugPrint(
        "Chat.fromJson: 'users' field is not a List in JSON: $json. Type received: ${usersData.runtimeType}",
      );
      throw FormatException(
        "Chat.fromJson: 'users' field is not a List. Received: ${usersData.runtimeType}",
      );
    }

    return Chat(
      id: json['id'] as int,
      name: json['name'] as String?,
      isGroup: json['is_group'] as int,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      imagePath: json['image_path'] as String?,
      users: parsedUsers,
    );
  }
}

class ChatUser {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final String? emailVerificationToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int countryId;
  final int roleId;
  final int activityStatus;
  final Pivot pivot;

  ChatUser({
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

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      debugPrint("ChatUser: 'id' field is null or missing in JSON: $json");
      throw const FormatException("ChatUser: 'id' field is null or missing.");
    }
    if (json['name'] == null) {
      debugPrint("ChatUser: 'name' field is null or missing in JSON: $json");
      throw const FormatException("ChatUser: 'name' field is null or missing.");
    }
    if (json['email'] == null) {
      debugPrint("ChatUser: 'email' field is null or missing in JSON: $json");
      throw const FormatException(
        "ChatUser: 'email' field is null or missing.",
      );
    }
    if (json['created_at'] == null) {
      debugPrint(
        "ChatUser: 'created_at' field is null or missing in JSON: $json",
      );
      throw const FormatException(
        "ChatUser: 'created_at' field is null or missing.",
      );
    }
    if (json['updated_at'] == null) {
      debugPrint(
        "ChatUser: 'updated_at' field is null or missing in JSON: $json",
      );
      throw const FormatException(
        "ChatUser: 'updated_at' field is null or missing.",
      );
    }
    if (json['country_id'] == null) {
      debugPrint(
        "ChatUser: 'country_id' field is null or missing in JSON: $json",
      );
      throw const FormatException(
        "ChatUser: 'country_id' field is null or missing.",
      );
    }
    if (json['role_id'] == null) {
      debugPrint("ChatUser: 'role_id' field is null or missing in JSON: $json");
      throw const FormatException(
        "ChatUser: 'role_id' field is null or missing.",
      );
    }
    if (json['activity_status'] == null) {
      debugPrint(
        "ChatUser: 'activity_status' field is null or missing in JSON: $json",
      );
      throw const FormatException(
        "ChatUser: 'activity_status' field is null or missing.",
      );
    }
    if (json['pivot'] == null) {
      debugPrint("ChatUser: 'pivot' field is null or missing in JSON: $json");
      throw const FormatException(
        "ChatUser: 'pivot' field is null or missing.",
      );
    }

    return ChatUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      emailVerifiedAt:
          json['email_verified_at'] != null &&
              json['email_verified_at'] is String
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      emailVerificationToken: json['email_verification_token'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      countryId: json['country_id'] as int,
      roleId: json['role_id'] as int,
      activityStatus: json['activity_status'] as int,
      pivot: Pivot.fromJson(json['pivot'] as Map<String, dynamic>),
    );
  }
}

class Pivot {
  final int chatId;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pivot({
    required this.chatId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pivot.fromJson(Map<String, dynamic> json) {
    if (json['chat_id'] == null) {
      debugPrint("Pivot: 'chat_id' field is null or missing in JSON: $json");
      throw const FormatException("Pivot: 'chat_id' field is null or missing.");
    }
    if (json['user_id'] == null) {
      debugPrint("Pivot: 'user_id' field is null or missing in JSON: $json");
      throw const FormatException("Pivot: 'user_id' field is null or missing.");
    }
    if (json['created_at'] == null) {
      debugPrint("Pivot: 'created_at' field is null or missing in JSON: $json");
      throw const FormatException(
        "Pivot: 'created_at' field is null or missing.",
      );
    }
    if (json['updated_at'] == null) {
      debugPrint("Pivot: 'updated_at' field is null or missing in JSON: $json");
      throw const FormatException(
        "Pivot: 'updated_at' field is null or missing.",
      );
    }

    return Pivot(
      chatId: json['chat_id'] as int,
      userId: json['user_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
