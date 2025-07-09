import 'package:dio/dio.dart';
import 'package:goreto/core/constants/api_endpoints.dart';

import 'secure_storage_service.dart';

class DioClient {
  late Dio dio;
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  DioClient._internal() {
    dio =
        Dio(
            BaseOptions(
              baseUrl: ApiEndpoints.baseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 20),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          )
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) async {
                final storage = SecureStorageService();
                final token = await storage.read('access_token');
                if (token != null) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
                return handler.next(options);
              },
              onError: (DioError e, handler) {
                return handler.next(e);
              },
            ),
          );
  }
}
