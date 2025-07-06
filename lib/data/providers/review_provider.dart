import 'package:flutter/material.dart';
import 'package:goreto/data/datasources/remote/review_api_service.dart';
import 'package:goreto/data/models/reviews/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewApiService apiService;

  ReviewProvider(this.apiService);

  List<ReviewModel> _reviews = [];
  bool _isLoading = false;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;

  Future<void> fetchReviews(int placeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _reviews = await apiService.getReviews(placeId);
    } catch (e) {
      _reviews = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
