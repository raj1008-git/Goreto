import 'package:dio/dio.dart';
import '../../../core/services/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../models/auth/login_response_model.dart';

class AuthApiService {
  final Dio _dio = DioClient().dio;

  Future<LoginResponse> login(String email, String password) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {"email": email, "password": password},
    );

    return LoginResponse.fromJson(response.data);
  }
}
