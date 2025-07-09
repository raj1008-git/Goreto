import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:goreto/data/models/chat/chat_model.dart';
import 'package:goreto/data/models/chat/message_model.dart';
import 'package:goreto/routes/app_routes.dart';
import '../../../data/models/chat/nearby_user_model.dart';
import '../../../data/models/chat/user_location_model.dart';
import '../../../data/datasources/remote/chat_api_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatApiService _api = ChatApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<NearbyUser> _nearbyUsers = [];
  List<NearbyUser> get nearbyUsers => _nearbyUsers;

  final List<Chat> _recentChats = [];
  List<Chat> get recentChats => _recentChats;

  Chat? _activeChat;
  Chat? get activeChat => _activeChat;

  List<Message> _messages = [];
  List<Message> get messages => _messages;

  Future<void> initiateChatWithUser(ChatUser user, BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final chat = await _api.createOrGetOneOnOneChat(user.id);
      _activeChat = chat;

      if (!_recentChats.any((c) => c.id == chat.id)) {
        _recentChats.add(chat);
      }

      await fetchMessages(chat.id);

      // Navigate to chat screen
      Navigator.pushNamed(context, AppRoutes.chatRoom, arguments: chat);
    } catch (e) {
      print('Chat initiation error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(int chatId) async {
    _messages = await _api.getMessages(chatId);
    notifyListeners();
  }

  /// Public method to send a message and get back the sent message from API
  Future<Message> sendMessageAndGetNew(int chatId, String message) async {
    final sentMessage = await _api.sendMessage(chatId, message);
    return sentMessage;
  }

  Future<void> sendMessage(String message) async {
    if (_activeChat == null) return;

    try {
      final newMessage = await sendMessageAndGetNew(_activeChat!.id, message);
      _messages.add(newMessage);
      notifyListeners();
    } catch (e) {
      print('Send message error: $e');
    }
  }

  Future<void> updateLocationAndFetchUsers() async {
    try {
      _isLoading = true;
      notifyListeners();

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _api.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final response = await _api.getNearbyUsers(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: 5000,
      );

      _nearbyUsers = response.data;
    } catch (e) {
      print("Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
