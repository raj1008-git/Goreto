import 'package:dio/dio.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';
import 'package:goreto/data/models/places/place_model.dart';

class PlaceApiService {
  final Dio dio;

  PlaceApiService(this.dio);

  Future<List<PlaceModel>> getPlacesByCategory() async {
    final storage = SecureStorageService();
    final token = await storage.read(
      'access_token',
    ); // ✅ your preferred approach

    if (token == null) {
      throw Exception('Access token not found');
    }

    final response = await dio.get(
      ApiEndpoints.placesByCategory,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final List<dynamic> data = response.data['data'];
    return data.map((e) => PlaceModel.fromJson(e)).toList();
  }
}
