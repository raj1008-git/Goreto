import 'package:dio/dio.dart';

import '../../../core/services/dio_client.dart';
import '../../models/places/place_model.dart';

class FavoritesService {
  final Dio _dio = DioClient().dio;

  // Add place to favorites
  Future<bool> addToFavorites(int locationId) async {
    try {
      final response = await _dio.post(
        '/favourites',
        data: {'location_id': locationId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  // Remove place from favorites
  Future<bool> removeFromFavorites(int locationId) async {
    try {
      final response = await _dio.delete('/favourites/$locationId');

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // Get all favorite places
  Future<List<PlaceModel>> getFavorites() async {
    try {
      final response = await _dio.get('/favourites');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) {
          // Assuming the API returns place data within the favorite item
          return PlaceModel.fromJson(item['place'] ?? item);
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  // Check if place is in favorites
  Future<bool> isFavorite(int locationId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((place) => place.id == locationId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }
}
