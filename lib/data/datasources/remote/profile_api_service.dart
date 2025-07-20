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
        return response.data['profile_picture'];
      }
      return null;
    } catch (e) {
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
      await dio.post(
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
    } catch (e) {
      throw Exception('Error changing password: $e');
    }
  }
}
