import 'package:flutter/foundation.dart';
import 'package:goreto/core/services/dio_client.dart';
import 'package:goreto/data/datasources/remote/place_api_service.dart';
import 'package:goreto/data/models/places/place_model.dart';
import 'package:goreto/data/models/places/popular_places_model.dart';

import '../datasources/remote/popular_places_api_service.dart';

// Isolate function for heavy JSON parsing
@pragma('vm:entry-point')
List<PlaceModel> _parseJsonInIsolate(List<dynamic> jsonData) {
  return jsonData.map((e) => PlaceModel.fromJson(e)).toList();
}

class OptimizedPlaceProvider with ChangeNotifier {
  List<PlaceModel> _places = [];
  List<PopularPlaceModel> _popularPlaces = []; // Keep as PopularPlaceModel
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<PlaceModel> get places => _places;
  List<PopularPlaceModel> get popularPlaces =>
      _popularPlaces; // Return PopularPlaceModel
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final _service = PlaceApiService(DioClient().dio);
  final _popularService = PopularPlaceApiService(DioClient().dio);

  // Optimized: Fetch both APIs concurrently
  Future<void> fetchAllPlaces() async {
    if (_isLoading) return; // Prevent multiple calls

    _setLoading(true);
    _errorMessage = null;

    try {
      // 🚀 CONCURRENT API calls instead of sequential
      final results = await Future.wait([
        _service.getPlacesByCategory(),
        _popularService.getPopularPlacesNearby(),
      ]);

      final placesData = results[0] as List<dynamic>;
      final popularPlacesData = results[1] as List<dynamic>;

      // 🧵 Use isolates for heavy JSON parsing (if data is large)
      if (placesData.length > 100 || popularPlacesData.length > 100) {
        final parsedResults = await Future.wait([
          compute(_parseJsonInIsolate, placesData),
          compute(_parsePopularJsonInIsolate, popularPlacesData),
        ]);

        _places = parsedResults[0] as List<PlaceModel>;
        _popularPlaces = parsedResults[1] as List<PopularPlaceModel>;
      } else {
        // For smaller datasets, parse on main thread
        _places = placesData.map((e) => PlaceModel.fromJson(e)).toList();
        _popularPlaces = popularPlacesData
            .map((e) => PopularPlaceModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      _errorMessage = "Failed to load places: ${e.toString()}";
      debugPrint("Error fetching places: $e");
    } finally {
      _setLoading(false);
    }
  }

  // 🔄 Refresh with pull-to-refresh
  Future<void> refreshPlaces() async {
    _places.clear();
    _popularPlaces.clear();
    await fetchAllPlaces();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear data on logout
  void clearData() {
    _places.clear();
    _popularPlaces.clear();
    _errorMessage = null;
    notifyListeners();
  }
}

// Separate isolate function for popular places
@pragma('vm:entry-point')
List<PopularPlaceModel> _parsePopularJsonInIsolate(List<dynamic> jsonData) {
  return jsonData.map((e) => PopularPlaceModel.fromJson(e)).toList();
}
