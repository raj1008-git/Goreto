class PlaceModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String description;
  final String imagePath;
  final String category;

  PlaceModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.imagePath,
    required this.category,
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
    );
  }
}
