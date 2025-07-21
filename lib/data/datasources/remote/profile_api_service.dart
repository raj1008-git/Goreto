// lib/data/datasources/remote/profile_api_service.dart

import 'package:dio/dio.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileApiService {
  final Dio dio;

  ProfileApiService(this.dio);

  Future<String?> getProfilePicture() async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    try {
      final response = await dio.get(
        ApiEndpoints.profilePicture,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 &&
          response.data['profile_picture'] != null) {
        // Extract the URL from the nested profile_picture object
        return response.data['profile_picture']['url'] as String?;
      }
      return null;
    } catch (e) {
      print('Error fetching profile picture: $e');
      // Profile picture not found or error
      return null;
    }
  }

  Future<bool> updateProfilePicture(XFile image) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    try {
      FormData formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
      });

      final response = await dio.post(
        ApiEndpoints.updateProfilePicture,
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating profile picture: $e');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    try {
      final response = await dio.post(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Check if the response was successful
      if (response.statusCode != 200) {
        throw Exception('Failed to change password');
      }
    } catch (e) {
      if (e is DioException) {
        // Handle different error status codes
        if (e.response?.statusCode == 400) {
          final errorData = e.response?.data;
          if (errorData is Map && errorData.containsKey('message')) {
            throw Exception(errorData['message']);
          } else if (errorData is Map && errorData.containsKey('errors')) {
            // Handle validation errors
            final errors = errorData['errors'] as Map;
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              throw Exception(firstError.first);
            }
          }
          throw Exception('Invalid request. Please check your passwords.');
        } else if (e.response?.statusCode == 401) {
          throw Exception('Current password is incorrect');
        } else if (e.response?.statusCode == 422) {
          throw Exception(
            'Password validation failed. New password may not meet requirements.',
          );
        } else {
          final errorMessage =
              e.response?.data['message'] ?? 'Failed to change password';
          throw Exception(errorMessage);
        }
      }
      throw Exception('Network error. Please try again.');
    }
  }
}
