import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';

class OptimizedPlaceApiService {
  final Dio dio;
  static String? _cachedToken; // Cache token to avoid repeated storage reads
  static DateTime? _tokenCacheTime;

  OptimizedPlaceApiService(this.dio);

  // 🚀 Get cached token or fetch from storage
  Future<String> _getAuthToken() async {
    final now = DateTime.now();

    // Use cached token if available and recent (< 30 minutes old)
    if (_cachedToken != null &&
        _tokenCacheTime != null &&
        now.difference(_tokenCacheTime!).inMinutes < 30) {
      return _cachedToken!;
    }

    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    // Cache the token
    _cachedToken = token;
    _tokenCacheTime = now;

    return token;
  }

  // 🔄 Return raw JSON data instead of parsed objects for isolate processing
  Future<List<dynamic>> getPlacesByCategory() async {
    final token = await _getAuthToken();

    final response = await dio.get(
      ApiEndpoints.placesByCategory,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // 📦 Enable response caching
        extra: {'cache': true},
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load places: ${response.statusCode}');
    }

    return response.data['data'] as List<dynamic>;
  }

  Future<List<dynamic>> getPopularPlacesNearby({
    double latitude = 27.6748,
    double longitude = 85.4274,
    int radius = 50000,
    int limit = 10,
    String category = "",
  }) async {
    final token = await _getAuthToken();

    final response = await dio.get(
      "${ApiEndpoints.baseUrl}/places/popular",
      queryParameters: {
        "latitude": latitude,
        "longitude": longitude,
        "radius": radius,
        "limit": limit,
        "category": category,
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        extra: {'cache': true},
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load popular places: ${response.statusCode}');
    }

    debugPrint(
      'Popular Places API response: ${response.data['data']?.length} items',
    );
    return response.data['data'] as List<dynamic>;
  }

  // Clear cached token on logout
  static void clearCache() {
    _cachedToken = null;
    _tokenCacheTime = null;
  }
}
