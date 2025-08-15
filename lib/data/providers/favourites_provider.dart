import 'package:flutter/material.dart';

import '../../data/models/places/place_model.dart';
import '../datasources/remote/favourite_service.dart';

class FavoritesProvider with ChangeNotifier {
  final FavoritesService _favoritesService = FavoritesService();

  List<PlaceModel> _favorites = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = false;
  String _error = '';

  List<PlaceModel> get favorites => _favorites;
  Set<int> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Check if a place is favorited
  bool isFavorite(int placeId) {
    return _favoriteIds.contains(placeId);
  }

  // Fetch all favorites
  Future<void> fetchFavorites() async {
    _setLoading(true);
    _error = '';

    try {
      final favoritesList = await _favoritesService.getFavorites();
      _favorites = favoritesList;
      _favoriteIds = favoritesList.map((place) => place.id).toSet();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load favorites: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(PlaceModel place) async {
    final bool wasAlreadyFavorite = isFavorite(place.id);

    // Optimistic update
    if (wasAlreadyFavorite) {
      _favoriteIds.remove(place.id);
      _favorites.removeWhere((p) => p.id == place.id);
    } else {
      _favoriteIds.add(place.id);
      _favorites.add(place);
    }
    notifyListeners();

    try {
      bool success;
      if (wasAlreadyFavorite) {
        success = await _favoritesService.removeFromFavorites(place.id);
      } else {
        success = await _favoritesService.addToFavorites(place.id);
      }

      if (!success) {
        // Revert optimistic update on failure
        if (wasAlreadyFavorite) {
          _favoriteIds.add(place.id);
          _favorites.add(place);
        } else {
          _favoriteIds.remove(place.id);
          _favorites.removeWhere((p) => p.id == place.id);
        }
        notifyListeners();
        return false;
      }

      return true;
    } catch (e) {
      // Revert optimistic update on error
      if (wasAlreadyFavorite) {
        _favoriteIds.add(place.id);
        _favorites.add(place);
      } else {
        _favoriteIds.remove(place.id);
        _favorites.removeWhere((p) => p.id == place.id);
      }
      notifyListeners();
      _error = 'Failed to update favorite: $e';
      return false;
    }
  }

  // Add specific place to favorites
  Future<bool> addToFavorites(PlaceModel place) async {
    if (isFavorite(place.id)) {
      return true; // Already in favorites
    }

    // Optimistic update
    _favoriteIds.add(place.id);
    _favorites.add(place);
    notifyListeners();

    try {
      final success = await _favoritesService.addToFavorites(place.id);
      if (!success) {
        // Revert on failure
        _favoriteIds.remove(place.id);
        _favorites.removeWhere((p) => p.id == place.id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      // Revert on error
      _favoriteIds.remove(place.id);
      _favorites.removeWhere((p) => p.id == place.id);
      notifyListeners();
      _error = 'Failed to add to favorites: $e';
      return false;
    }
  }

  // Remove specific place from favorites
  Future<bool> removeFromFavorites(PlaceModel place) async {
    if (!isFavorite(place.id)) {
      return true; // Already not in favorites
    }

    // Optimistic update
    _favoriteIds.remove(place.id);
    _favorites.removeWhere((p) => p.id == place.id);
    notifyListeners();

    try {
      final success = await _favoritesService.removeFromFavorites(place.id);
      if (!success) {
        // Revert on failure
        _favoriteIds.add(place.id);
        _favorites.add(place);
        notifyListeners();
      }
      return success;
    } catch (e) {
      // Revert on error
      _favoriteIds.add(place.id);
      _favorites.add(place);
      notifyListeners();
      _error = 'Failed to remove from favorites: $e';
      return false;
    }
  }

  // Clear all favorites locally (not from server)
  void clearFavorites() {
    _favorites.clear();
    _favoriteIds.clear();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
