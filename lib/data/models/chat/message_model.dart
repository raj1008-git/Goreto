// lib/data/models/chat/message_model.dart

import 'chat_models.dart';

class MessageModel {
  final int? id;
  final int chatId;
  final String messages;
  final int sentBy;
  final String sentAt;
  final String createdAt;
  final String updatedAt;
  final ChatModel? chat;
  final bool isLoading; // For local state management
  final bool hasError; // For error handling

  MessageModel({
    this.id,
    required this.chatId,
    required this.messages,
    required this.sentBy,
    required this.sentAt,
    required this.createdAt,
    required this.updatedAt,
    this.chat,
    this.isLoading = false,
    this.hasError = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      chatId: json['chat_id'],
      messages: json['messages'],
      sentBy: json['sent_by'],
      sentAt: json['sent_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      chat: json['chat'] != null ? ChatModel.fromJson(json['chat']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'messages': messages,
      'sent_by': sentBy,
      'sent_at': sentAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'chat': chat?.toJson(),
    };
  }

  // Create a temporary message for immediate UI update
  factory MessageModel.createTemporary({
    required int chatId,
    required String messages,
    required int sentBy,
  }) {
    final now = DateTime.now().toIso8601String();
    return MessageModel(
      chatId: chatId,
      messages: messages,
      sentBy: sentBy,
      sentAt: now,
      createdAt: now,
      updatedAt: now,
      isLoading: true,
    );
  }

  // Create a copy with updated fields
  MessageModel copyWith({
    int? id,
    int? chatId,
    String? messages,
    int? sentBy,
    String? sentAt,
    String? createdAt,
    String? updatedAt,
    ChatModel? chat,
    bool? isLoading,
    bool? hasError,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      messages: messages ?? this.messages,
      sentBy: sentBy ?? this.sentBy,
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      chat: chat ?? this.chat,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }
}

class SendMessageRequest {
  final int chatId;
  final String messages;

  SendMessageRequest({required this.chatId, required this.messages});

  Map<String, dynamic> toJson() {
    return {'chat_id': chatId, 'messages': messages};
  }
}

class SendMessageResponse {
  final String message;
  final MessageModel data;

  SendMessageResponse({required this.message, required this.data});

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      message: json['message'],
      data: MessageModel.fromJson(json['data']),
    );
  }
}
