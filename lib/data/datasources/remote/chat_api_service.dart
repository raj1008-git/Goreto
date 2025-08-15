// // lib/data/datasources/remote/chat_api_service.dart
//
// import 'package:dio/dio.dart';
// import 'package:goreto/core/constants/api_endpoints.dart';
// import 'package:goreto/core/services/secure_storage_service.dart';
//
// import '../../models/chat/chat_models.dart';
// import '../../models/chat/message_model.dart';
//
// class ChatApiService {
//   final Dio dio;
//
//   ChatApiService(this.dio);
//
//   Future<CreateChatResponse> createOrFetchOneOnOneChat(int userId) async {
//     final storage = SecureStorageService();
//     final token = await storage.read('access_token');
//
//     if (token == null) {
//       throw Exception('Access token not found');
//     }
//
//     final response = await dio.post(
//       '${ApiEndpoints.baseUrl}/chats/one-on-one',
//       data: {'user_id': userId},
//       options: Options(
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       ),
//     );
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       return CreateChatResponse.fromJson(response.data);
//     } else {
//       throw Exception(
//         'Failed to create or fetch chat: ${response.statusMessage}',
//       );
//     }
//   }
//
//   Future<SendMessageResponse> sendMessage(SendMessageRequest request) async {
//     final storage = SecureStorageService();
//     final token = await storage.read('access_token');
//
//     if (token == null) {
//       throw Exception('Access token not found');
//     }
//
//     try {
//       final response = await dio.post(
//         '${ApiEndpoints.baseUrl}/chats/send',
//         data: request.toJson(),
//         options: Options(
//           headers: {
//             'Accept': 'application/json',
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//         ),
//       );
//
//       return SendMessageResponse.fromJson(response.data);
//     } on DioException catch (e) {
//       if (e.response != null) {
//         throw Exception(
//           'Failed to send message: ${e.response?.data['message'] ?? 'Unknown error'}',
//         );
//       } else {
//         throw Exception('Network error: ${e.message}');
//       }
//     } catch (e) {
//       throw Exception('Unexpected error: $e');
//     }
//   }
//
//   Future<List<MessageModel>> fetchMessages(int chatId) async {
//     final token = await SecureStorageService().read('access_token');
//
//     final response = await dio.get(
//       "${ApiEndpoints.baseUrl}/chats/$chatId",
//       options: Options(
//         headers: {
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       ),
//     );
//
//     final List<dynamic> messagesData = response.data['messages'];
//     return messagesData.map((e) => MessageModel.fromJson(e)).toList();
//   }
// }
// lib/data/datasources/remote/chat_api_service.dart

import 'package:dio/dio.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';

import '../../models/chat/chat_models.dart';
import '../../models/chat/message_model.dart';

class ChatApiService {
  final Dio dio;

  ChatApiService(this.dio);

  /// Create or fetch one-on-one chat
  Future<CreateChatResponse> createOrFetchOneOnOneChat(int userId) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    final response = await dio.post(
      '${ApiEndpoints.baseUrl}/chats/one-on-one',
      data: {'user_id': userId},
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CreateChatResponse.fromJson(response.data);
    } else {
      throw Exception(
        'Failed to create or fetch chat: ${response.statusMessage}',
      );
    }
  }

  /// Send message to either one-on-one or group chat
  /// The chat_id should be the group_chat_id for group chats
  Future<SendMessageResponse> sendMessage(SendMessageRequest request) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    try {
      print('🚀 Sending message to chat ID: ${request.chatId}');
      print('📝 Message content: ${request.messages}');

      final response = await dio.post(
        '${ApiEndpoints.baseUrl}/chats/send',
        data: request.toJson(),
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('✅ Message sent successfully. Status: ${response.statusCode}');
      print('📨 Response data: ${response.data}');

      return SendMessageResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Dio error sending message: ${e.message}');
      print('❌ Response data: ${e.response?.data}');

      if (e.response != null) {
        throw Exception(
          'Failed to send message: ${e.response?.data['message'] ?? 'Unknown error'}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unexpected error sending message: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch messages for a chat (works for both one-on-one and group chats)
  /// The chatId should be the group_chat_id for group chats
  Future<List<MessageModel>> fetchMessages(int chatId) async {
    try {
      final token = await SecureStorageService().read('access_token');

      if (token == null) {
        throw Exception('Access token not found');
      }

      print('🔍 Fetching messages for chat ID: $chatId');

      final response = await dio.get(
        "${ApiEndpoints.baseUrl}/chats/$chatId",
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('✅ Messages fetched successfully. Status: ${response.statusCode}');
      print('📨 Messages count: ${response.data['messages']?.length ?? 0}');

      final List<dynamic> messagesData = response.data['messages'] ?? [];
      final messages = messagesData
          .map((e) => MessageModel.fromJson(e))
          .toList();

      // Sort messages by sent_at timestamp to ensure correct order
      messages.sort(
        (a, b) => DateTime.parse(a.sentAt).compareTo(DateTime.parse(b.sentAt)),
      );

      return messages;
    } on DioException catch (e) {
      print('❌ Dio error fetching messages: ${e.message}');
      print('❌ Response data: ${e.response?.data}');

      if (e.response != null) {
        throw Exception(
          'Failed to fetch messages: ${e.response?.data['message'] ?? 'Unknown error'}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unexpected error fetching messages: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get chat details (useful for getting chat info)
  Future<Map<String, dynamic>> getChatDetails(int chatId) async {
    try {
      final token = await SecureStorageService().read('access_token');

      if (token == null) {
        throw Exception('Access token not found');
      }

      final response = await dio.get(
        "${ApiEndpoints.baseUrl}/chats/$chatId/details",
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to get chat details: ${e.response?.data['message'] ?? 'Unknown error'}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(int chatId) async {
    try {
      final token = await SecureStorageService().read('access_token');

      if (token == null) {
        throw Exception('Access token not found');
      }

      await dio.post(
        "${ApiEndpoints.baseUrl}/chats/$chatId/mark-read",
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('✅ Messages marked as read for chat ID: $chatId');
    } on DioException catch (e) {
      print('❌ Failed to mark messages as read: ${e.message}');
      // Don't throw error for this operation as it's not critical
    } catch (e) {
      print('❌ Unexpected error marking messages as read: $e');
    }
  }
}
