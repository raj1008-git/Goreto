import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:goreto/core/services/location_service.dart';
import 'package:goreto/core/services/pusher_service.dart';
import 'package:goreto/core/services/secure_storage_service.dart';
import 'package:goreto/data/datasources/remote/chat_api_service.dart';
import 'package:goreto/data/models/chat/chat_creation_response_model.dart';
import 'package:goreto/data/models/chat/message_model.dart';
import 'package:goreto/data/models/chat/nearby_users_response_model.dart';

class ChatProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final ChatApiService _chatApiService = ChatApiService();
  final PusherService _pusherService = PusherService();
  final SecureStorageService _secureStorageService = SecureStorageService();

  List<NearbyUser> _nearbyUsers = [];
  List<NearbyUser> get nearbyUsers => _nearbyUsers;

  bool _isLoadingNearbyUsers = false;
  bool get isLoadingNearbyUsers => _isLoadingNearbyUsers;

  bool _isSendingLocation = false;
  bool get isSendingLocation => _isSendingLocation;

  Chat? _currentChat;
  Chat? get currentChat => _currentChat;

  List<Message> _messages = [];
  List<Message> get messages => _messages;

  bool _isLoadingMessages = false;
  bool get isLoadingMessages => _isLoadingMessages;

  int? _currentUserId;
  int? get currentUserId => _currentUserId;

  ChatProvider() {
    _pusherService.messageEventNotifier.addListener(_handleIncomingMessage);
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    String? userIdString = await _secureStorageService.read('user_id');
    if (userIdString != null) {
      _currentUserId = int.tryParse(userIdString);
      debugPrint("Current User ID Loaded from SecureStorage: $_currentUserId");
    } else {
      _currentUserId = 3;
      debugPrint(
        "Current User ID Hardcoded (SecureStorage null): $_currentUserId",
      );
    }
    notifyListeners();
  }

  void _handleIncomingMessage() {
    final event = _pusherService.messageEventNotifier.value;
    if (event != null) {
      try {
        Map<String, dynamic> eventPayload;

        if (event.data is Map<String, dynamic>) {
          eventPayload = event.data as Map<String, dynamic>;
        } else if (event.data is String) {
          eventPayload = jsonDecode(event.data);
        } else {
          debugPrint(
            "Pusher event data is neither Map nor String: ${event.data.runtimeType}",
          );
          return;
        }

        debugPrint("Incoming Pusher Event Payload: $eventPayload");

        Map<String, dynamic>? messageData;
        if (eventPayload.containsKey('message') &&
            eventPayload['message'] is Map<String, dynamic>) {
          messageData = eventPayload['message'] as Map<String, dynamic>;
        } else {
          messageData = eventPayload;
          debugPrint(
            "Pusher event payload did not contain 'message' key. Assuming entire payload is message data.",
          );
        }

        if (messageData == null) {
          debugPrint("Could not find valid message data in Pusher event.");
          return;
        }

        if (_currentChat != null &&
            messageData['chat_id'] == _currentChat!.id) {
          if (messageData['id'] == null ||
              messageData['sent_by'] == null ||
              messageData['messages'] == null ||
              messageData['sent_at'] == null) {
            debugPrint(
              "Incoming Pusher message missing essential fields: $messageData",
            );
            return;
          }

          final newMessage = Message.fromJson(messageData);

          if (!_messages.any((msg) => msg.id == newMessage.id)) {
            _messages.add(newMessage);

            _messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
            debugPrint("Added new message from Pusher: ${newMessage.messages}");
            notifyListeners();
          } else {
            debugPrint(
              "Duplicate message from Pusher (ID: ${newMessage.id}), not adding.",
            );
          }
        } else {
          debugPrint(
            "Incoming Pusher message for different chat or no active chat. Current Chat ID: ${_currentChat?.id}, Event Chat ID: ${messageData['chat_id']}",
          );
        }
      } catch (e) {
        debugPrint("Error parsing or handling incoming Pusher message: $e");
        debugPrint("Raw Pusher event data that caused error: ${event?.data}");
      }
    }
  }

  Future<void> sendAndFetchNearbyUsers() async {
    _isSendingLocation = true;
    notifyListeners();
    _isLoadingNearbyUsers = true;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        await _chatApiService.sendUserLocation(
          position.latitude,
          position.longitude,
        );
        debugPrint(
          "User location sent: ${position.latitude}, ${position.longitude}",
        );

        final nearbyUsersResponse = await _chatApiService.fetchNearbyUsers(
          position.latitude,
          position.longitude,
        );
        _nearbyUsers = nearbyUsersResponse.data;
        debugPrint("Fetched ${_nearbyUsers.length} nearby users.");
      } else {
        _nearbyUsers = [];
        debugPrint("Could not get current location to fetch nearby users.");
      }
    } catch (e) {
      debugPrint("Error in sendAndFetchNearbyUsers: $e");
      _nearbyUsers = [];
    } finally {
      _isSendingLocation = false;
      _isLoadingNearbyUsers = false;
      notifyListeners();
    }
  }

  Future<void> createAndNavigateToChat(int targetUserId) async {
    try {
      final response = await _chatApiService.createOneOnOneChat(targetUserId);
      _currentChat = response.chat;
      _messages = [];

      if (_currentChat?.id != null) {
        await _pusherService.subscribeToChannel(
          'private-chat.${_currentChat!.id}',
        );
        debugPrint(
          "Subscribed to Pusher channel: private-chat.${_currentChat!.id}",
        );
      } else {
        debugPrint(
          "Error: Current chat ID is null, cannot subscribe to Pusher channel.",
        );
      }

      await fetchMessagesForCurrentChat();

      debugPrint("Chat created/fetched with ID: ${_currentChat?.id}");
      notifyListeners();
    } catch (e) {
      debugPrint("Error creating/fetching chat: $e");
      _currentChat = null;
      _messages = [];
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchMessagesForCurrentChat() async {
    if (_currentChat == null) {
      debugPrint("No current chat to fetch messages for.");
      _messages = [];
      notifyListeners();
      return;
    }
    _isLoadingMessages = true;
    notifyListeners();
    try {
      final fetchedMessages = await _chatApiService.getChatMessages(
        _currentChat!.id,
      );
      _messages = fetchedMessages..sort((a, b) => a.sentAt.compareTo(b.sentAt));
      debugPrint(
        "Fetched ${_messages.length} messages for chat ID: ${_currentChat!.id}",
      );

      if (_messages.isEmpty) {
        debugPrint(
          "DEBUG: fetchedMessages is empty for chat ID: ${_currentChat!.id}",
        );
      } else {
        debugPrint("DEBUG: First fetched message: ${_messages.first.messages}");
      }
    } catch (e) {
      debugPrint("Error fetching messages: $e");
      _messages = [];
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String messageContent) async {
    if (_currentChat == null || _currentUserId == null) {
      debugPrint("No active chat or current user to send message from.");
      return;
    }

    final tempMessage = Message(
      id: -1,
      chatId: _currentChat!.id,
      sentBy: _currentUserId!,
      messages: messageContent,
      sentAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _messages.add(tempMessage);
    _messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    notifyListeners();

    try {
      final response = await _chatApiService.sendMessage(
        _currentChat!.id,
        messageContent,
      );

      final confirmedMessage = Message(
        id: response.data.id,
        chatId: response.data.chatId,
        sentBy: response.data.sentBy,
        messages: response.data.messages,
        sentAt: response.data.sentAt,
        createdAt: response.data.createdAt,
        updatedAt: response.data.updatedAt,
      );

      final index = _messages.indexWhere(
        (msg) =>
            msg.id == tempMessage.id && msg.messages == tempMessage.messages,
      );
      if (index != -1) {
        _messages[index] = confirmedMessage;
      } else {
        _messages.add(confirmedMessage);
      }
      _messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
      notifyListeners();

      debugPrint(
        "Message sent and confirmed by API: ${response.data.messages}",
      );
    } catch (e) {
      debugPrint("Error sending message: $e");

      _messages.remove(tempMessage);
      notifyListeners();
      rethrow;
    }
  }

  void clearCurrentChat() {
    if (_currentChat != null && _currentChat!.id != null) {
      _pusherService.unsubscribeFromChannel('private-chat.${_currentChat!.id}');
      debugPrint(
        "Unsubscribed from Pusher channel: private-chat.${_currentChat!.id}",
      );
    }
    _currentChat = null;
    _messages = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _pusherService.messageEventNotifier.removeListener(_handleIncomingMessage);
    super.dispose();
  }
}
