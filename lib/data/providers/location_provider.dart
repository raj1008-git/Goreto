// lib/providers/location_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:goreto/core/services/secure_storage_service.dart';

import '../datasources/remote/location_api_service.dart';
import '../datasources/remote/location_service.dart';
import '../models/Location/location_model.dart';
import '../models/chat/nearby_user_model.dart';

class LocationProvider extends ChangeNotifier {
  final LocationApiService _locationApiService = LocationApiService(Dio());
  final SecureStorageService _secureStorage = SecureStorageService();

  bool _isLocationLoading = false;
  bool _isNearbyUsersLoading = false;
  String? _locationError;
  String? _nearbyUsersError;

  LocationModel? _currentLocation;
  List<NearbyUserModel> _nearbyUsers = [];

  double? _latitude;
  double? _longitude;

  // Getters
  bool get isLocationLoading => _isLocationLoading;
  bool get isNearbyUsersLoading => _isNearbyUsersLoading;
  String? get locationError => _locationError;
  String? get nearbyUsersError => _nearbyUsersError;
  LocationModel? get currentLocation => _currentLocation;
  List<NearbyUserModel> get nearbyUsers => _nearbyUsers;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  // Initialize provider by loading stored location
  Future<void> initialize() async {
    await _loadStoredLocation();
    if (_latitude != null && _longitude != null) {
      await fetchNearbyUsers();
    }
  }

  // Load location from secure storage
  Future<void> _loadStoredLocation() async {
    try {
      final lat = await _secureStorage.read('latitude');
      final lon = await _secureStorage.read('longitude');

      if (lat != null && lon != null) {
        _latitude = double.parse(lat);
        _longitude = double.parse(lon);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading stored location: $e');
    }
  }

  // Update user location
  Future<String?> updateLocation() async {
    try {
      _isLocationLoading = true;
      _locationError = null;
      notifyListeners();

      // Request location permission
      bool hasPermission = await LocationService.requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }

      // Get current location
      final position = await LocationService.getCurrentLocation();
      if (position == null) {
        throw Exception('Unable to get current location');
      }

      // Update location on server
      final response = await _locationApiService.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Store location locally
      _currentLocation = response.data;
      _latitude = position.latitude;
      _longitude = position.longitude;

      await _secureStorage.write('latitude', position.latitude.toString());
      await _secureStorage.write('longitude', position.longitude.toString());

      // Fetch nearby users after location update
      await fetchNearbyUsers();

      _isLocationLoading = false;
      notifyListeners();

      return response.message;
    } catch (e) {
      _isLocationLoading = false;
      _locationError = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Fetch nearby users
  Future<void> fetchNearbyUsers() async {
    if (_latitude == null || _longitude == null) return;

    try {
      _isNearbyUsersLoading = true;
      _nearbyUsersError = null;
      notifyListeners();

      final response = await _locationApiService.getNearbyUsers(
        latitude: _latitude!,
        longitude: _longitude!,
      );

      _nearbyUsers = response.data;
      _isNearbyUsersLoading = false;
      notifyListeners();
    } catch (e) {
      _isNearbyUsersLoading = false;
      _nearbyUsersError = e.toString();
      notifyListeners();
    }
  }

  // Clear location data
  void clearLocationData() async {
    _currentLocation = null;
    _latitude = null;
    _longitude = null;
    _nearbyUsers = [];

    await _secureStorage.delete('latitude');
    await _secureStorage.delete('longitude');

    notifyListeners();
  }
}
