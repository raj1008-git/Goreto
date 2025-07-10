import 'package:flutter/foundation.dart';

import 'chat_creation_response_model.dart';

class MessageSendResponse {
  final String message;
  final MessageData data;

  MessageSendResponse({required this.message, required this.data});

  factory MessageSendResponse.fromJson(Map<String, dynamic> json) {
    if (json['message'] == null) {
      debugPrint(
        "MessageSendResponse: 'message' field is null or missing in JSON: $json",
      );
      throw const FormatException(
        "MessageSendResponse: 'message' field is null or missing.",
      );
    }
    if (json['data'] == null) {
      debugPrint(
        "MessageSendResponse: 'data' field is null or missing in JSON: $json",
      );
      throw const FormatException(
        "MessageSendResponse: 'data' field is null or missing.",
      );
    }

    return MessageSendResponse(
      message: json['message'] as String,
      data: MessageData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class MessageData {
  final int chatId;
  final String messages;
  final int sentBy;
  final DateTime sentAt;
  final DateTime updatedAt;
  final DateTime createdAt;
  final int id;
  final Chat chat;

  MessageData({
    required this.chatId,
    required this.messages,
    required this.sentBy,
    required this.sentAt,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
    required this.chat,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    if (json['chat_id'] == null) {
      debugPrint(
        "MessageData: 'chat_id' field is null or missing in JSON: $json",
      );
      throw const FormatException(
        "MessageData: 'chat_id' field is null or missing.",
      );
    }
    if (json['messages'] == null) {
      debugPrint(
        "MessageData: 'messages' field is null or missing in JSON: $json",
      );
      throw const FormatException(
        "MessageData: 'messages' field is null or missing.",
      );
    }
    if (json['sent_by'] == null) {
      debugPrint(
        "MessageData: 'sent_by' field is null or missing in JSON: $json",
      );
      throw const FormatException(
        "MessageData: 'sent_by' field is null or missing.",
      );
    }
    if (json['sent_at'] == null) {
      debugPrint(
        "MessageData: 'sent_at' field is null or missing in JSON: $json",
      );
      throw const FormatException(
        "MessageData: 'sent_at' field is null or missing.",
      );
    }
    if (json['updated_at'] == null) {
      debugPrint(
        "MessageData: 'updated_at' field is null or missing in JSON: $json",
      );
      throw const FormatException(
        "MessageData: 'updated_at' field is null or missing.",
      );
    }
    if (json['created_at'] == null) {
      debugPrint(
        "MessageData: 'created_at' field is null or missing in JSON: $json",
      );
      throw const FormatException(
        "MessageData: 'created_at' field is null or missing.",
      );
    }
    if (json['id'] == null) {
      debugPrint("MessageData: 'id' field is null or missing in JSON: $json");
      throw const FormatException(
        "MessageData: 'id' field is null or missing.",
      );
    }

    if (json['chat'] == null) {
      debugPrint("MessageData: 'chat' field is null or missing in JSON: $json");
      throw const FormatException(
        "MessageData: 'chat' field is null or missing. This might contain the 'users' list causing the error.",
      );
    }

    return MessageData(
      chatId: json['chat_id'] as int,
      messages: json['messages'] as String,
      sentBy: json['sent_by'] as int,
      sentAt: DateTime.parse(json['sent_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      id: json['id'] as int,
      chat: Chat.fromJson(json['chat'] as Map<String, dynamic>),
    );
  }
}
