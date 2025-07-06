import 'package:flutter/material.dart';
import 'package:goreto/data/datasources/remote/place_api_service.dart';
import 'package:goreto/core/services/dio_client.dart';
import 'package:goreto/data/models/places/place_model.dart';

class PlaceProvider with ChangeNotifier {
  List<PlaceModel> _places = [];
  bool _isLoading = false;

  List<PlaceModel> get places => _places;
  bool get isLoading => _isLoading;

  final _service = PlaceApiService(DioClient().dio);

  Future<void> fetchPlaces() async {
    _isLoading = true;
    notifyListeners();
    try {
      _places = await _service.getPlacesByCategory();
    } catch (e) {
      debugPrint("Error fetching places: $e");
    }
    _isLoading = false;
    notifyListeners();
  }
}
