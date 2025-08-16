// lib/data/datasources/remote/notification_api_service.dart
import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../models/notification/notification_model.dart';

class NotificationApiService {
  final Dio dio;

  NotificationApiService(this.dio);

  Future<NotificationResponse> fetchNotifications({int page = 1}) async {
    try {
      final token = await SecureStorageService().read('access_token');

      if (token == null) {
        throw Exception('Access token not found');
      }

      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/post-notifications',
        queryParameters: {'page': page},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('✅ Notifications fetched successfully');
      return NotificationResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error fetching notifications: ${e.message}');
      throw Exception('Failed to fetch notifications: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }
}
