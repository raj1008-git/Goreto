import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';

import '../../models/places/popular_places_model.dart';

class PopularPlaceApiService {
  final Dio dio;

  PopularPlaceApiService(this.dio);

  Future<List<PopularPlaceModel>> getPopularPlacesNearby() async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');
    print("🔐 Access token read: $token");
    if (token == null) throw Exception('Access token not found');

    final response = await dio.get(
      "${ApiEndpoints.baseUrl}/places/popular",
      queryParameters: {
        "latitude": 27.6748,
        "longitude": 85.4274,
        "radius": 50000,
        "limit": 10,
        "category": "",
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    debugPrint('Popular Places API response status: ${response.statusCode}');
    debugPrint('Popular Places API response data: ${response.data}');

    final List<dynamic> data = response.data['data'];
    debugPrint('Popular Places API extracted data length: ${data.length}');
    return data.map((e) => PopularPlaceModel.fromJson(e)).toList();
  }
}
