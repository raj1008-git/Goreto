// lib/data/datasources/remote/category_api_service.dart

import 'package:dio/dio.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';

import '../../models/category/category_model.dart';

class CategoryApiService {
  final Dio dio;

  CategoryApiService(this.dio);

  Future<CategoryPaginationData> getCategories({int page = 1}) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    final response = await dio.get(
      '${ApiEndpoints.baseUrl}/categories',
      queryParameters: {'page': page},
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final categoryResponse = CategoryResponse.fromJson(response.data);
    return categoryResponse.data;
  }

  Future<Map<String, dynamic>> saveUserCategories(
    List<String> categories,
  ) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    final response = await dio.post(
      '${ApiEndpoints.baseUrl}/categories',
      data: {'categories': categories},
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return response.data;
  }
}
