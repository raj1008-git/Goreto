
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../constants/api_endpoints.dart';

class PusherService {
  final String apiUrl;
  final String pusherKey;
  final String cluster;
  final String authToken;

  late PusherChannelsFlutter _pusher;
  bool _isConnected = false;
  String? _currentChannel;

  Function(Map<String, dynamic>)? onNewMessage;

  PusherService({
    required this.apiUrl,
    required this.pusherKey,
    required this.cluster,
    required this.authToken,
  });

  Future<void> init(String chatId) async {
    try {
      _pusher = PusherChannelsFlutter.getInstance();
      _currentChannel = 'private-chat.$chatId';

      await _pusher.init(
        apiKey: pusherKey,
        cluster: cluster,
        onConnectionStateChange: _onConnectionStateChange,
        onError: _onError,
        onSubscriptionSucceeded: _onSubscriptionSucceeded,
        onEvent: _onEvent,
        onSubscriptionError: _onSubscriptionError,
        onDecryptionFailure: _onDecryptionFailure,
        onMemberAdded: _onMemberAdded,
        onMemberRemoved: _onMemberRemoved,
        authEndpoint: '${ApiEndpoints.baseUrl}/broadcasting/auth',
        onAuthorizer: _onAuthorizer,
      );

      // Subscribe to the channel
      await _pusher.subscribe(channelName: _currentChannel!);

      // Connect to Pusher
      await _pusher.connect();

      print('✅ Pusher initialized for channel: $_currentChannel');
    } catch (e) {
      print('❌ Pusher initialization error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _onAuthorizer(
    String channelName,
    String socketId,
    dynamic options,
  ) async {
    try {
      final url = Uri.parse('${ApiEndpoints.baseUrl}/broadcasting/auth');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'socket_id': socketId, 'channel_name': channelName}),
      );

      print('🔐 Auth request for $channelName: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('🔐 Auth response: $jsonResponse');
        return jsonResponse;
      } else {
        print('❌ Auth failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to authorize channel: ${response.body}');
      }
    } catch (e) {
      print('❌ Authorization error: $e');
      rethrow;
    }
  }

  void _onConnectionStateChange(dynamic currentState, dynamic previousState) {
    print('🔗 Connection state changed: $previousState -> $currentState');
    _isConnected = currentState == 'connected';
  }

  void _onError(String message, int? code, dynamic e) {
    print('❌ Pusher error: $message (code: $code)');
  }

  void _onEvent(PusherEvent event) {
    print('🔥 Event received: ${event.eventName}');
    print('🔥 Event data: ${event.data}');
    print('🔥 Event channel: ${event.channelName}');

    // Skip Pusher internal events
    if (event.eventName.startsWith('pusher:')) {
      print('⏭️ Skipping internal Pusher event: ${event.eventName}');
      return;
    }

    // Handle all non-pusher events as potential message events
    // This will catch any event name your backend sends
    try {
      if (event.data != null && event.data!.isNotEmpty) {
        final data = jsonDecode(event.data!);
        print('📨 Processing event data: $data');

        if (onNewMessage != null) {
          onNewMessage!(data);
        }
      } else {
        print('⚠️ Event has no data: ${event.eventName}');
      }
    } catch (e) {
      print('❌ Error parsing event data: $e');
      print('❌ Raw event data: ${event.data}');
    }
  }

  void _onSubscriptionSucceeded(String channelName, dynamic data) {
    print('✅ Successfully subscribed to: $channelName');
    print('📊 Subscription data: $data');
  }

  void _onSubscriptionError(String message, dynamic e) {
    print('❌ Subscription error: $message');
    print('❌ Error details: $e');
  }

  void _onDecryptionFailure(String event, String reason) {
    print('🔒 Decryption failure for $event: $reason');
  }

  void _onMemberAdded(String channelName, PusherMember member) {
    print('👋 Member added to $channelName: ${member.userInfo}');
  }

  void _onMemberRemoved(String channelName, PusherMember member) {
    print('👋 Member removed from $channelName: ${member.userInfo}');
  }

  Future<void> disconnect(String chatId) async {
    try {
      if (_currentChannel != null) {
        await _pusher.unsubscribe(channelName: _currentChannel!);
        print('🔌 Unsubscribed from $_currentChannel');
      }
      await _pusher.disconnect();
      print('🔌 Disconnected from Pusher');
      _isConnected = false;
    } catch (e) {
      print('❌ Error disconnecting: $e');
    }
  }

  bool get isConnected => _isConnected;
  String? get currentChannel => _currentChannel;
}
