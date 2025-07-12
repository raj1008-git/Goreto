import 'package:flutter/material.dart';
import 'package:goreto/core/services/dio_client.dart';

import '../datasources/remote/popular_places_api_service.dart';
import '../models/places/popular_places_model.dart';

class PopularPlaceProvider with ChangeNotifier {
  List<PopularPlaceModel> _popularPlaces = [];
  bool _isLoading = false;

  List<PopularPlaceModel> get popularPlaces => _popularPlaces;
  bool get isLoading => _isLoading;

  final _service = PopularPlaceApiService(DioClient().dio);

  Future<void> fetchPopularPlacesNearby() async {
    _isLoading = true;
    notifyListeners();

    try {
      print("📡 Fetching popular places...");
      _popularPlaces = await _service.getPopularPlacesNearby();
      print("✅ Popular places fetched: ${_popularPlaces.length}");
    } catch (e) {
      print("❌ Error fetching popular places: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
