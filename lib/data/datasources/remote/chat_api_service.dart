// lib/data/datasources/remote/chat_api_service.dart

import 'package:dio/dio.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';

import '../../models/chat/chat_models.dart';
import '../../models/chat/message_model.dart';

class ChatApiService {
  final Dio dio;

  ChatApiService(this.dio);

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

  Future<SendMessageResponse> sendMessage(SendMessageRequest request) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    try {
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

      return SendMessageResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to send message: ${e.response?.data['message'] ?? 'Unknown error'}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
