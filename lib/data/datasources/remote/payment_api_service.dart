// lib/data/datasources/remote/payment_api_service.dart

import 'package:dio/dio.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';

class PaymentApiService {
  final Dio dio;
  final SecureStorageService _storage = SecureStorageService();

  PaymentApiService(this.dio);

  /// Creates a payment intent using your backend API
  Future<Map<String, dynamic>> createPaymentIntent({
    required int subscriptionId,
    List<String> paymentMethodTypes = const ["card"],
  }) async {
    try {
      final token = await _storage.read('access_token');
      if (token == null) {
        throw Exception("No authentication token found");
      }

      final response = await dio.post(
        '${ApiEndpoints.baseUrl}/payments',
        data: {
          'subscription_id': subscriptionId,
          'payment_method_types': paymentMethodTypes,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        // Validate required fields
        if (!data.containsKey('client_secret')) {
          throw Exception("Missing client_secret in response");
        }
        if (!data.containsKey('payment_id')) {
          throw Exception("Missing payment_id in response");
        }
        if (!data.containsKey('user_id')) {
          throw Exception("Missing user_id in response");
        }

        return data;
      } else {
        throw Exception(
          "Failed to create payment intent: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception("Authentication failed. Please login again.");
      } else if (e.response?.statusCode == 422) {
        throw Exception("Invalid subscription ID or payment method");
      } else {
        throw Exception("Network error: ${e.message}");
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Calls the payment success API after successful payment
  Future<Map<String, dynamic>> confirmPaymentSuccess({
    required int userId,
    required int paymentId,
  }) async {
    try {
      final token = await _storage.read('access_token');
      if (token == null) {
        throw Exception("No authentication token found");
      }

      final response = await dio.post(
        '${ApiEndpoints.baseUrl}/payment-success/$paymentId',
        data: {'user_id': userId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return data;
      } else {
        throw Exception(
          "Failed to confirm payment success: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception("Authentication failed. Please login again.");
      } else if (e.response?.statusCode == 404) {
        throw Exception("Payment not found for this user");
      } else {
        throw Exception("Network error: ${e.message}");
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Helper method to get stored auth token
  Future<String?> getAuthToken() async {
    return await _storage.read('access_token');
  }
}
