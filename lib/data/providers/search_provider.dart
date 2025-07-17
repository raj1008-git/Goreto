import 'package:flutter/material.dart';
// import 'package:goreto/features/search/services/search_api_service.dart';
import 'package:goreto/core/services/dio_client.dart';
import 'package:goreto/data/models/places/place_model.dart';

import '../datasources/remote/search_api_service.dart';

class SearchProvider extends ChangeNotifier {
  final SearchApiService _apiService = SearchApiService(DioClient().dio);

  List<PlaceModel> _results = [];
  bool _isLoading = false;

  List<PlaceModel> get results => _results;
  bool get isLoading => _isLoading;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _results = await _apiService.searchPlaces(query);
    } catch (e) {
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _results = [];
    notifyListeners();
  }
}
