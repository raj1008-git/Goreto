// lib/data/datasources/remote/location_api_service.dart

import 'package:dio/dio.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';

import '../../models/Location/location_model.dart';
import '../../models/chat/nearby_user_model.dart';

class LocationApiService {
  final Dio dio;

  LocationApiService(this.dio);

  Future<LocationResponse> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    final response = await dio.post(
      ApiEndpoints.userLocation,
      data: {'latitude': latitude, 'longitude': longitude},
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return LocationResponse.fromJson(response.data);
  }

  Future<NearbyUsersResponse> getNearbyUsers({
    required double latitude,
    required double longitude,
    double radius = 5000, // Default 5km radius
  }) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    final response = await dio.post(
      ApiEndpoints.nearbyUsers,
      data: {'latitude': latitude, 'longitude': longitude, 'radius': radius},
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return NearbyUsersResponse.fromJson(response.data);
  }
}
