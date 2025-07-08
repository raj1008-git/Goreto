import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/chat/nearby_user_model.dart';
import '../../../data/models/chat/user_location_model.dart';
import '../../../data/datasources/remote/chat_api_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatApiService _api = ChatApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<NearbyUser> _nearbyUsers = [];
  List<NearbyUser> get nearbyUsers => _nearbyUsers;

  Future<void> updateLocationAndFetchUsers() async {
    try {
      _isLoading = true;
      notifyListeners();

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _api.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final response = await _api.getNearbyUsers(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: 5000,
      );

      _nearbyUsers = response.data;
    } catch (e) {
      print("Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
