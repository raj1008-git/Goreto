import 'package:dio/dio.dart';
import 'package:goreto/data/models/chat/chat_model.dart';
import 'package:goreto/data/models/chat/message_model.dart';
import '../../../core/services/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../models/chat/user_location_model.dart';
import '../../models/chat/nearby_user_model.dart';

class ChatApiService {
  final Dio _dio = DioClient().dio;

  Future<UserLocationResponse> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.userLocation,
      data: {"latitude": latitude, "longitude": longitude},
    );
    return UserLocationResponse.fromJson(response.data);
  }

  Future<NearbyUserResponse> getNearbyUsers({
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.nearbyUsers,
      data: {"latitude": latitude, "longitude": longitude, "radius": radius},
    );
    return NearbyUserResponse.fromJson(response.data);
  }

  Future<Chat> createOrGetOneOnOneChat(int userId) async {
    final response = await _dio.post(
      '/chats/one-on-one',
      data: {"user_id": userId},
    );
    return Chat.fromJson(response.data['chat']);
  }

  Future<Message> sendMessage(int chatId, String message) async {
    final response = await _dio.post(
      '/chats/send',
      data: {"chat_id": chatId, "messages": message},
    );
    // Assuming the API response contains the sent message data inside 'data'
    return Message.fromJson(response.data['data']);
  }

  Future<List<Message>> getMessages(int chatId) async {
    final response = await _dio.get('/chats/$chatId');
    return List<Message>.from(
      response.data['messages'].map((x) => Message.fromJson(x)),
    );
  }
}
