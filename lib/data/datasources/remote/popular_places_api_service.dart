// lib/data/datasources/remote/popular_places_api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';
import 'package:goreto/data/models/places/place_model.dart';

import '../../../core/utils/place_parser.dart';

class PopularPlacesApiService {
  final Dio dio;

  PopularPlacesApiService(this.dio);

  Future<List<PlaceModel>> getPopularPlaces({
    required double latitude,
    required double longitude,
    required String category,
    int radius = 50000,
    int limit = 10,
  }) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    final response = await dio.get(
      '${ApiEndpoints.baseUrl}/places/popular',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'limit': '',
        'category': '',
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];
      return await compute(parsePlaces, data); // decode in isolate
    } else {
      throw Exception('Failed to fetch popular places');
    }
  }
}
