import 'package:dio/dio.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';
import 'package:goreto/data/models/places/place_model.dart';

class SearchApiService {
  final Dio dio;

  SearchApiService(this.dio);

  Future<List<PlaceModel>> searchPlaces(String query) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) throw Exception('No access token found');

    final response = await dio.get(
      '${ApiEndpoints.baseUrl}/places/search',
      queryParameters: {'query': query},
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final data = response.data['data'] as List<dynamic>;
    return data.map((json) => PlaceModel.fromJson(json)).toList();
  }
}
