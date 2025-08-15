// lib/core/services/chat_channel_manager.dart

import 'package:flutter/material.dart';

import '../../data/models/chat/message_model.dart';
import 'pusher_service.dart';
import 'secure_storage_service.dart';

/// Manages multiple chat channels and Pusher connections
class ChatChannelManager {
  static final ChatChannelManager _instance = ChatChannelManager._internal();
  factory ChatChannelManager() => _instance;
  ChatChannelManager._internal();

  final Map<String, PusherService> _activeChannels = {};
  final Map<String, Function(MessageModel)> _messageHandlers = {};

  /// Initialize a chat channel
  Future<bool> initializeChannel({
    required String chatId,
    required bool isGroupChat,
    required Function(MessageModel) onMessage,
  }) async {
    try {
      final channelKey = _getChannelKey(chatId, isGroupChat);

      // Check if channel is already active
      if (_activeChannels.containsKey(channelKey)) {
        print('📡 Channel $channelKey already active');
        // Update message handler
        _messageHandlers[channelKey] = onMessage;
        return true;
      }

      final storage = SecureStorageService();
      final authToken = await storage.read('access_token');

      if (authToken == null) {
        print('❌ No auth token found for channel $channelKey');
        return false;
      }

      print('🚀 Initializing channel: $channelKey');

      final pusherService = PusherService(
        apiUrl: 'http://110.34.1.123:8080/api', // Use your API base URL
        pusherKey: 'b788ecec8a643e0034b6',
        cluster: 'ap2',
        authToken: authToken,
      );

      // Set up message handler
      pusherService.onNewMessage = (data) =>
          _handleChannelMessage(channelKey, data);

      // Store handlers
      _activeChannels[channelKey] = pusherService;
      _messageHandlers[channelKey] = onMessage;

      // Initialize Pusher
      await pusherService.init(chatId);

      print('✅ Channel $channelKey initialized successfully');
      return true;
    } catch (e) {
      print('❌ Failed to initialize channel $chatId: $e');
      return false;
    }
  }

  /// Handle incoming message for a specific channel
  void _handleChannelMessage(String channelKey, Map<String, dynamic> data) {
    try {
      print('📨 Message received for channel: $channelKey');
      print('📨 Raw data: $data');

      // Extract message data
      Map<String, dynamic> messageData = data;
      if (data.containsKey('message') && data['message'] is Map) {
        messageData = Map<String, dynamic>.from(data['message']);
      } else if (data.containsKey('data') && data['data'] is Map) {
        messageData = Map<String, dynamic>.from(data['data']);
      }

      // Create message model
      final message = MessageModel.fromJson(messageData);

      // Call the registered handler
      final handler = _messageHandlers[channelKey];
      if (handler != null) {
        handler(message);
        print('📨 Message handled by channel: $channelKey');
      } else {
        print('⚠️ No handler registered for channel: $channelKey');
      }
    } catch (e) {
      print('❌ Error handling message for channel $channelKey: $e');
      print('❌ Raw data: $data');
    }
  }

  /// Disconnect from a channel
  Future<void> disconnectChannel({
    required String chatId,
    required bool isGroupChat,
  }) async {
    try {
      final channelKey = _getChannelKey(chatId, isGroupChat);
      final pusherService = _activeChannels[channelKey];

      if (pusherService != null) {
        await pusherService.disconnect(chatId);
        _activeChannels.remove(channelKey);
        _messageHandlers.remove(channelKey);
        print('🔌 Disconnected from channel: $channelKey');
      }
    } catch (e) {
      print('❌ Error disconnecting channel $chatId: $e');
    }
  }

  /// Disconnect all channels
  Future<void> disconnectAll() async {
    print('🔌 Disconnecting all channels...');

    for (final entry in _activeChannels.entries) {
      try {
        final chatId = entry.key.split('_')[1]; // Extract chat ID from key
        await entry.value.disconnect(chatId);
        print('🔌 Disconnected channel: ${entry.key}');
      } catch (e) {
        print('❌ Error disconnecting channel ${entry.key}: $e');
      }
    }

    _activeChannels.clear();
    _messageHandlers.clear();
    print('✅ All channels disconnected');
  }

  /// Check if a channel is active
  bool isChannelActive({required String chatId, required bool isGroupChat}) {
    final channelKey = _getChannelKey(chatId, isGroupChat);
    return _activeChannels.containsKey(channelKey);
  }

  /// Get connection status for a channel
  bool isChannelConnected({required String chatId, required bool isGroupChat}) {
    final channelKey = _getChannelKey(chatId, isGroupChat);
    final pusherService = _activeChannels[channelKey];
    return pusherService?.isConnected ?? false;
  }

  /// Get channel key for internal tracking
  String _getChannelKey(String chatId, bool isGroupChat) {
    return isGroupChat ? 'group_$chatId' : 'private_$chatId';
  }

  /// Get active channels count
  int get activeChannelsCount => _activeChannels.length;

  /// Get active channels info
  List<String> get activeChannels => _activeChannels.keys.toList();
}

/// Simplified interface for chat screens
class ChatChannelHelper {
  /// Initialize chat for a screen
  static Future<bool> initializeChat({
    required String chatId,
    required bool isGroupChat,
    required Function(MessageModel) onMessage,
  }) async {
    final manager = ChatChannelManager();
    return await manager.initializeChannel(
      chatId: chatId,
      isGroupChat: isGroupChat,
      onMessage: onMessage,
    );
  }

  /// Cleanup chat for a screen
  static Future<void> cleanupChat({
    required String chatId,
    required bool isGroupChat,
  }) async {
    final manager = ChatChannelManager();
    await manager.disconnectChannel(chatId: chatId, isGroupChat: isGroupChat);
  }

  /// Check if chat is connected
  static bool isChatConnected({
    required String chatId,
    required bool isGroupChat,
  }) {
    final manager = ChatChannelManager();
    return manager.isChannelConnected(chatId: chatId, isGroupChat: isGroupChat);
  }
}

/// Widget mixin to automatically handle chat channel lifecycle
mixin ChatChannelMixin<T extends StatefulWidget> on State<T> {
  String get chatId;
  bool get isGroupChat;
  Function(MessageModel) get onMessageReceived;

  bool _isChannelInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeChannel();
  }

  @override
  void dispose() {
    _cleanupChannel();
    super.dispose();
  }

  Future<void> _initializeChannel() async {
    final success = await ChatChannelHelper.initializeChat(
      chatId: chatId,
      isGroupChat: isGroupChat,
      onMessage: onMessageReceived,
    );

    if (mounted) {
      setState(() {
        _isChannelInitialized = success;
      });
    }
  }

  Future<void> _cleanupChannel() async {
    await ChatChannelHelper.cleanupChat(
      chatId: chatId,
      isGroupChat: isGroupChat,
    );
  }

  bool get isChannelInitialized => _isChannelInitialized;
  bool get isChannelConnected => ChatChannelHelper.isChatConnected(
    chatId: chatId,
    isGroupChat: isGroupChat,
  );
}
