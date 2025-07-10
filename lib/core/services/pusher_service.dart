import 'package:flutter/foundation.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import 'dio_client.dart';

class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;

  late PusherChannelsFlutter pusher;
  final SecureStorageService _secureStorageService = SecureStorageService();

  final ValueNotifier<PusherEvent?> _messageEventNotifier = ValueNotifier(null);
  ValueNotifier<PusherEvent?> get messageEventNotifier => _messageEventNotifier;

  PusherService._internal() {
    pusher = PusherChannelsFlutter.getInstance();
  }

  Future<void> initPusher() async {
    try {
      final accessToken = await _secureStorageService.read('access_token');
      if (accessToken == null) {
        debugPrint(
          "PusherService: Access token not found. Cannot initialize Pusher. Ensure user is logged in.",
        );
        return;
      }

      await pusher.init(
        apiKey: ApiEndpoints.pusherAppKey,
        cluster: ApiEndpoints.pusherAppCluster,
        onConnectionStateChange: onConnectionStateChange,
        onError: onError,
        onEvent: onEvent,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onSubscriptionError: onSubscriptionError,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
        authEndpoint: ApiEndpoints.pusherAuthEndpoint,
        onAuthorizer: onAuthorizer,
      );
      debugPrint(
        "Pusher initialized successfully with auth endpoint: ${ApiEndpoints.pusherAuthEndpoint}",
      );
    } catch (e) {
      debugPrint("Pusher Initialization Error: $e");
    }
  }

  Future<void> connect() async {
    try {
      await pusher.connect();
      debugPrint("Pusher connected.");
    } catch (e) {
      debugPrint("Pusher Connection Error: $e");
    }
  }

  Future<void> disconnect() async {
    try {
      await pusher.disconnect();
      debugPrint("Pusher disconnected.");
    } catch (e) {
      debugPrint("Pusher Disconnection Error: $e");
    }
  }

  Future<void> subscribeToChannel(String channelName) async {
    try {
      await pusher.subscribe(channelName: channelName);
      debugPrint("Subscribed to channel: $channelName");
    } catch (e) {
      debugPrint("Subscription Error for $channelName: $e");
    }
  }

  Future<void> unsubscribeFromChannel(String channelName) async {
    try {
      await pusher.unsubscribe(channelName: channelName);
      debugPrint("Unsubscribed from channel: $channelName");
    } catch (e) {
      debugPrint("Unsubscription Error for $channelName: $e");
    }
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    debugPrint("Pusher Connection State: $previousState -> $currentState");
  }

  void onError(String message, int? code, dynamic e) {
    debugPrint("Pusher Error: $message (Code: $code, Exception: $e)");

    if (e.toString().contains("AuthorizationFailureException")) {
      debugPrint(
        "Pusher Authorization Failure Detected: Check backend auth endpoint response and token setup in DioClient.",
      );
    }
  }

  void onEvent(PusherEvent event) {
    debugPrint(
      "Pusher Event: ${event.channelName}/${event.eventName} Data: ${event.data}",
    );

    if (event.eventName == 'message_sent' &&
        event.channelName?.startsWith('private-chat.') == true) {
      _messageEventNotifier.value = event;
    }
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    debugPrint("Pusher Subscription Succeeded: $channelName Data: $data");
  }

  void onSubscriptionError(String message, dynamic e) {
    debugPrint("Pusher Subscription Error: $message Exception: $e");
  }

  void onMemberAdded(String channelName, PusherMember member) {
    debugPrint("Pusher Member Added: $channelName User: ${member.userId}");
  }

  void onMemberRemoved(String channelName, PusherMember member) {
    debugPrint("Pusher Member Removed: $channelName User: ${member.userId}");
  }

  dynamic onAuthorizer(
    String channelName,
    String socketId,
    dynamic options,
  ) async {
    debugPrint("Authorizing channel: $channelName, socketId: $socketId");
    try {
      final dio = DioClient().dio;

      final response = await dio.post(
        ApiEndpoints.pusherAuthEndpoint,
        data: {'socket_id': socketId, 'channel_name': channelName},
      );

      debugPrint("Pusher Authorization Raw Response: ${response.data}");

      if (response.data is Map<String, dynamic> &&
          response.data.containsKey('auth')) {
        debugPrint("Pusher Authorization Response parsed successfully.");
        return response.data;
      } else {
        debugPrint(
          "Pusher Authorization Response format invalid. Expected 'auth' key. Response: ${response.data}",
        );
        throw Exception(
          "Invalid authorization response from backend. Expected 'auth' and 'shared_secret' (optional) fields.",
        );
      }
    } catch (e) {
      debugPrint("Pusher Authorization Error during POST request: $e");

      rethrow;
    }
  }

  void dispose() {
    _messageEventNotifier.dispose();
    disconnect();
  }
}
