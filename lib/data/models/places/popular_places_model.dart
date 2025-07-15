import 'package:goreto/data/models/places/place_model.dart';

class PopularPlaceModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String description;
  final String imagePath;
  final String category;
  final int categoryId; // ✅ NEW
  final double? distance;

  PopularPlaceModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.imagePath,
    required this.category,
    required this.categoryId, // ✅ NEW
    this.distance,
  });

  factory PopularPlaceModel.fromJson(Map<String, dynamic> json) {
    final imageList = json['location_images'] as List<dynamic>;

    return PopularPlaceModel(
      id: json['id'],
      name: json['name'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      description: json['description'],
      imagePath: imageList.isNotEmpty
          ? imageList[0]['image_url']
          : 'https://via.placeholder.com/200x160.png?text=No+Image',
      category: json['category']?['category'] ?? 'Unknown',
      categoryId: json['category_id'], // ✅ NEW
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
    );
  }

  PlaceModel toPlaceModel() {
    return PlaceModel(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      description: description,
      imagePath: imagePath,
      category: category,
      categoryId: categoryId, // ✅ NEW
      distance: distance,
    );
  }
}
