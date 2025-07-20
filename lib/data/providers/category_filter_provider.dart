import 'package:flutter/material.dart';
import 'package:goreto/core/services/dio_client.dart';
import 'package:goreto/data/models/places/place_model.dart';

import '../datasources/remote/category_filter_api_service.dart';

class CategoryFilterProvider with ChangeNotifier {
  List<PlaceModel> _categoryPlaces = [];
  bool _isLoading = false;
  String? _selectedCategory;
  bool _isFilterMode = false;

  List<PlaceModel> get categoryPlaces => _categoryPlaces;
  bool get isLoading => _isLoading;
  String? get selectedCategory => _selectedCategory;
  bool get isFilterMode => _isFilterMode;

  final _service = CategoryFilterApiService(DioClient().dio);

  Future<void> fetchPlacesByCategory(String category) async {
    _isLoading = true;
    _selectedCategory = category;
    _isFilterMode = true;
    notifyListeners();

    try {
      _categoryPlaces = await _service.getPlacesByCategory(category: category);
    } catch (e) {
      debugPrint("Error fetching places by category: $e");
      _categoryPlaces = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearFilter() {
    _categoryPlaces = [];
    _selectedCategory = null;
    _isFilterMode = false;
    _isLoading = false;
    notifyListeners();
  }
}
