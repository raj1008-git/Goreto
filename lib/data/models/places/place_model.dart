class PlaceModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String description;
  final String imagePath;
  final String category;
  final int categoryId; // ✅ NEW
  final double? distance;

  PlaceModel({
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

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'],
      name: json['name'],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      description: json['description'],
      imagePath: json['location_images'][0]['image_url'],
      category: json['category']['category'],
      categoryId: json['category_id'], // ✅ NEW
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
    );
  }
}
