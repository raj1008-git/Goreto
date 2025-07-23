// lib/data/providers/popular_places_provider.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../datasources/remote/popular_places_api_service.dart';
import '../models/places/place_model.dart';

class PopularPlacesProvider extends ChangeNotifier {
  final PopularPlacesApiService _apiService;

  PopularPlacesProvider(this._apiService);

  // State variables
  List<PlaceModel> _places = [];
  List<String> _selectedCategories = [];
  String? _currentSelectedCategory;
  bool _isLoading = false;
  String? _error;
  double? _userLatitude;
  double? _userLongitude;

  // Getters
  List<PlaceModel> get places => _places;
  List<String> get selectedCategories => _selectedCategories;
  String? get currentSelectedCategory => _currentSelectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double? get userLatitude => _userLatitude;
  double? get userLongitude => _userLongitude;

  // Load selected categories from SharedPreferences
  Future<void> loadSelectedCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString('selected_categories');

      if (categoriesJson != null) {
        final List<dynamic> categoriesList = json.decode(categoriesJson);
        _selectedCategories = categoriesList.cast<String>();

        // Set first category as default if available
        if (_selectedCategories.isNotEmpty &&
            _currentSelectedCategory == null) {
          _currentSelectedCategory = _selectedCategories.first;
        }
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to load selected categories: $e';
      notifyListeners();
    }
  }

  // Save selected categories to SharedPreferences
  Future<void> saveSelectedCategories(List<String> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_categories', json.encode(categories));
      _selectedCategories = categories;

      // Reset current selection if it's not in the new list
      if (!categories.contains(_currentSelectedCategory)) {
        _currentSelectedCategory = categories.isNotEmpty
            ? categories.first
            : null;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save selected categories: $e';
      notifyListeners();
    }
  }

  // Set user location
  void setUserLocation(double latitude, double longitude) {
    _userLatitude = latitude;
    _userLongitude = longitude;
    notifyListeners();
  }

  // Change selected category
  void changeSelectedCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _currentSelectedCategory = category;
      notifyListeners();

      // Automatically fetch places for the new category
      if (_userLatitude != null && _userLongitude != null) {
        fetchPopularPlaces();
      }
    }
  }

  // Fetch popular places based on current selection
  Future<void> fetchPopularPlaces() async {
    if (_currentSelectedCategory == null ||
        _userLatitude == null ||
        _userLongitude == null) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final places = await _apiService.getPopularPlaces(
        latitude: _userLatitude!,
        longitude: _userLongitude!,
        category: _currentSelectedCategory!,
      );

      _places = places;
    } catch (e) {
      _error = 'Failed to fetch popular places: $e';
      _places = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh places
  Future<void> refreshPlaces() async {
    await fetchPopularPlaces();
  }

  // Clear all data
  void clear() {
    _places.clear();
    _currentSelectedCategory = null;
    _error = null;
    _userLatitude = null;
    _userLongitude = null;
    notifyListeners();
  }

  // Get place by id
  PlaceModel? getPlaceById(int id) {
    try {
      return _places.firstWhere((place) => place.id == id);
    } catch (e) {
      return null;
    }
  }
}
