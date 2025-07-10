import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/dio_client.dart';
import 'package:goreto/data/models/chat/chat_creation_response_model.dart';
import 'package:goreto/data/models/chat/message_model.dart';
import 'package:goreto/data/models/chat/message_send_response_model.dart';
import 'package:goreto/data/models/chat/nearby_users_response_model.dart';
import 'package:goreto/data/models/chat/user_location_response_model.dart';

class ChatApiService {
  final Dio _dio = DioClient().dio;

  Future<UserLocationResponse> sendUserLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.userLocation,
        data: {"latitude": latitude, "longitude": longitude},
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw Exception(
          "Invalid or null response data from sendUserLocation API. Raw response: ${response.data}",
        );
      }
      return UserLocationResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint(
        "DioError sending user location: ${e.response?.data ?? e.message}",
      );
      throw Exception(
        "Failed to send user location: ${e.response?.data['message'] ?? e.message}",
      );
    } catch (e) {
      debugPrint("Unexpected error sending user location: $e");
      throw Exception("An unexpected error occurred: $e");
    }
  }

  Future<NearbyUsersResponse> fetchNearbyUsers(
    double latitude,
    double longitude, {
    int radius = 5000,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.nearbyUsers,
        data: {"latitude": latitude, "longitude": longitude, "radius": radius},
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw Exception(
          "Invalid or null response data from fetchNearbyUsers API. Raw response: ${response.data}",
        );
      }
      return NearbyUsersResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint(
        "DioError fetching nearby users: ${e.response?.data ?? e.message}",
      );
      throw Exception(
        "Failed to fetch nearby users: ${e.response?.data['message'] ?? e.message}",
      );
    } catch (e) {
      debugPrint("Unexpected error fetching nearby users: $e");
      throw Exception("An unexpected error occurred: $e");
    }
  }

  Future<ChatCreationResponse> createOneOnOneChat(int userId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createOneOnOneChat,
        data: {"user_id": userId},
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw Exception(
          "Invalid or null response data from createOneOnOneChat API. Raw response: ${response.data}",
        );
      }
      return ChatCreationResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint(
        "DioError creating one-on-one chat: ${e.response?.data ?? e.message}",
      );
      throw Exception(
        "Failed to create one-on-one chat: ${e.response?.data['message'] ?? e.message}",
      );
    } catch (e) {
      debugPrint("Unexpected error creating one-on-one chat: $e");
      throw Exception("An unexpected error occurred: $e");
    }
  }

  Future<MessageSendResponse> sendMessage(int chatId, String message) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.sendMessage,
        data: {"chat_id": chatId, "messages": message},
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw Exception(
          "Invalid or null response data from sendMessage API. Raw response: ${response.data}",
        );
      }
      return MessageSendResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint("DioError sending message: ${e.response?.data ?? e.message}");
      throw Exception(
        "Failed to send message: ${e.response?.data['message'] ?? e.message}",
      );
    } catch (e) {
      debugPrint("Unexpected error sending message: $e");
      throw Exception("An unexpected error occurred: $e");
    }
  }

  Future<List<Message>> getChatMessages(int chatId) async {
    try {
      final response = await _dio.get(ApiEndpoints.getChatMessages(chatId));

      debugPrint("API Response for getChatMessages: ${response.data}");

      if (response.data == null) {
        throw Exception("Null response data from getChatMessages API.");
      }

      if (response.data is List) {
        debugPrint("getChatMessages: Response is a direct List.");
        return (response.data as List)
            .map(
              (messageJson) =>
                  Message.fromJson(messageJson as Map<String, dynamic>),
            )
            .toList();
      } else if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseMap =
            response.data as Map<String, dynamic>;

        if (responseMap.containsKey('data') && responseMap['data'] is List) {
          debugPrint("getChatMessages: Response has 'data' key as a List.");
          return (responseMap['data'] as List)
              .map(
                (messageJson) =>
                    Message.fromJson(messageJson as Map<String, dynamic>),
              )
              .toList();
        } else if (responseMap.containsKey('messages') &&
            responseMap['messages'] is List) {
          debugPrint("getChatMessages: Response has 'messages' key as a List.");
          return (responseMap['messages'] as List)
              .map(
                (messageJson) =>
                    Message.fromJson(messageJson as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw Exception(
            "Invalid response format for chat messages: Expected a List or a Map with a 'data' or 'messages' List. Received a Map with keys: ${responseMap.keys.join(', ')}",
          );
        }
      } else {
        throw Exception(
          "Invalid response format for chat messages: Expected a List or a Map. Received: ${response.data.runtimeType}",
        );
      }
    } on DioException catch (e) {
      debugPrint(
        "DioError fetching chat messages: ${e.response?.data ?? e.message}",
      );
      throw Exception(
        "Failed to fetch chat messages: ${e.response?.data['message'] ?? e.message}",
      );
    } catch (e) {
      debugPrint("Unexpected error fetching chat messages: $e");
      throw Exception("An unexpected error occurred: $e");
    }
  }
}
