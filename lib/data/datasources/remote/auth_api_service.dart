// import 'package:dio/dio.dart';
// import '../../../core/services/dio_client.dart';
// import '../../../core/constants/api_endpoints.dart';
// import '../../models/auth/login_response_model.dart';
//
// class AuthApiService {
//   final Dio _dio = DioClient().dio;
//
//   Future<LoginResponse> login(String email, String password) async {
//     final response = await _dio.post(
//       ApiEndpoints.login,
//       data: {"email": email, "password": password},
//     );
//
//     return LoginResponse.fromJson(response.data);
//   }
// }
import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/dio_client.dart';
import '../../models/auth/login_response_model.dart';
import '../../models/auth/register_response_model.dart';

class AuthApiService {
  final Dio _dio = DioClient().dio;

  Future<LoginResponse> login(String email, String password) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {"email": email, "password": password},
    );

    return LoginResponse.fromJson(response.data);
  }

  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String country,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": passwordConfirmation,
        "country": country,
      },
    );

    return RegisterResponse.fromJson(response.data);
  }

  Future<Map<String, dynamic>> verifyEmail(String token) async {
    final response = await _dio.post(
      ApiEndpoints.verifyEmail,
      data: {"token": token},
    );

    return response.data;
  }
}
