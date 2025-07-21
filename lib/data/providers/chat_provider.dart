// lib/data/providers/chat_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../datasources/remote/chat_api_service.dart';
import '../models/chat/chat_models.dart';

class ChatProvider extends ChangeNotifier {
  final ChatApiService _chatApiService = ChatApiService(Dio());

  bool _isCreatingChat = false;
  String? _createChatError;
  ChatModel? _currentChat;

  // Getters
  bool get isCreatingChat => _isCreatingChat;
  String? get createChatError => _createChatError;
  ChatModel? get currentChat => _currentChat;

  // Create or fetch one-on-one chat
  Future<ChatModel?> createOrFetchOneOnOneChat(int userId) async {
    try {
      _isCreatingChat = true;
      _createChatError = null;
      notifyListeners();

      final response = await _chatApiService.createOrFetchOneOnOneChat(userId);
      _currentChat = response.chat;

      _isCreatingChat = false;
      notifyListeners();

      return response.chat;
    } catch (e) {
      _isCreatingChat = false;
      _createChatError = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Clear current chat
  void clearCurrentChat() {
    _currentChat = null;
    _createChatError = null;
    notifyListeners();
  }

  // Get other user in one-on-one chat
  ChatUserModel? getOtherUserInChat(ChatModel chat, int currentUserId) {
    try {
      return chat.users.firstWhere((user) => user.id != currentUserId);
    } catch (e) {
      return null;
    }
  }
}
