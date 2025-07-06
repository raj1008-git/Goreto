import 'package:dio/dio.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';
import 'package:goreto/data/models/reviews/review_model.dart';

class ReviewApiService {
  final Dio dio;

  ReviewApiService(this.dio);

  Future<List<ReviewModel>> getReviews(int placeId) async {
    final token = await SecureStorageService().read('access_token');

    final response = await dio.get(
      "${ApiEndpoints.baseUrl}/location-reviews/$placeId",
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final List<dynamic> data = response.data['data'];
    return data.map((e) => ReviewModel.fromJson(e)).toList();
  }
}
