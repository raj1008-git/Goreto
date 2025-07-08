import 'package:dio/dio.dart';
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
}
