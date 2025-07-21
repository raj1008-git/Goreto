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

  Function(Map<String, dynamic>)? onNewMessage;

  PusherService({
    required this.apiUrl,
    required this.pusherKey,
    required this.cluster,
    required this.authToken,
  });

  Future<void> init(String chatId) async {
    _pusher = PusherChannelsFlutter.getInstance();

    await _pusher.init(
      apiKey: pusherKey,
      cluster: cluster,

      // Fix here: only 2 parameters, socketId extracted from options map
      onAuthorizer: (String channelName, String socketId, dynamic options) async {
        final url = Uri.parse('${ApiEndpoints.baseUrl}/broadcasting/auth');
        final body = jsonEncode({
          'channel_name': channelName,
          'socket_id': socketId,
        });

        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          body: body,
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> respData = jsonDecode(response.body);
          return {
            'auth': respData['auth'],
            if (respData.containsKey('channel_data'))
              'channel_data': respData['channel_data'],
          };
        } else {
          throw Exception(
            'Pusher authorization failed: ${response.statusCode} ${response.reasonPhrase}',
          );
        }
      },

      onEvent: (event) {
        print('Event received: ${event.eventName}');
        if (event.eventName == 'message.sent' && event.data != null) {
          final Map<String, dynamic> data = jsonDecode(event.data!);
          // Your logic for handling new message event goes here
          print('New message data: $data');

          if (onNewMessage != null) {
            onNewMessage!(data);
          }
        }
      },

      onSubscriptionSucceeded: (String channelName, dynamic data) {
        print('Subscribed to $channelName successfully.');
      },

      onSubscriptionError: (String channelName, dynamic error) {
        print('Subscription error on $channelName: $error');
      },

      // onConnectionError: (String message) {
      //   print('Connection error: $message');
      // },
    );

    await _pusher.subscribe(channelName: 'private-chat.$chatId');
    await _pusher.connect();
  }

  Future<void> disconnect(String chatId) async {
    await _pusher.unsubscribe(channelName: 'private-chat.$chatId');
    await _pusher.disconnect();
  }
}
