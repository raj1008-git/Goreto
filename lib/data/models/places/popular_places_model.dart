import 'package:equatable/equatable.dart';

class PopularPlaceModel extends Equatable {
  final int id;
  final String placeId;
  final String name;
  final double latitude;
  final double longitude;
  final int cityId;
  final String description;
  final double? averageRating;
  final double distance;
  final List<String> locationImages;
  final int categoryId;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PopularPlaceModel({
    required this.id,
    required this.placeId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.cityId,
    required this.description,
    this.averageRating,
    required this.distance,
    required this.locationImages,
    required this.categoryId,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PopularPlaceModel.fromJson(Map<String, dynamic> json) {
    try {
      return PopularPlaceModel(
        id: _parseIntSafely(json['id']),
        placeId: json['place_id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unknown Place',
        latitude: _parseDoubleSafely(json['latitude']) ?? 0.0,
        longitude: _parseDoubleSafely(json['longitude']) ?? 0.0,

        cityId: _parseIntSafely(json['city_id']),
        description:
            json['description']?.toString() ?? 'No description available',
        averageRating: _parseDoubleSafely(json['average_rating']),
        distance: _parseDoubleSafely(json['distance']) ?? 0.0,
        locationImages: _parseImagesList(json['location_images']),
        categoryId: _parseCategoryId(json['category']),
        category: _parseCategoryName(json['category']),
        createdAt: _parseDateTimeSafely(json['created_at']),
        updatedAt: _parseDateTimeSafely(json['updated_at']),
      );
    } catch (e) {
      throw FormatException('Failed to parse PopularPlaceModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'place_id': placeId,
      'name': name,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'city_id': cityId,
      'description': description,
      'average_rating': averageRating?.toString(),
      'distance': distance,
      'location_images': locationImages
          .map((url) => {'image_url': url})
          .toList(),
      'category': {'id': categoryId, 'category': category},
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PopularPlaceModel copyWith({
    int? id,
    String? placeId,
    String? name,
    double? latitude,
    double? longitude,
    int? cityId,
    String? description,
    double? averageRating,
    double? distance,
    List<String>? locationImages,
    int? categoryId,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PopularPlaceModel(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityId: cityId ?? this.cityId,
      description: description ?? this.description,
      averageRating: averageRating ?? this.averageRating,
      distance: distance ?? this.distance,
      locationImages: locationImages ?? this.locationImages,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods for safe parsing
  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double? _parseDoubleSafely(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<String> _parseImagesList(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];

    return value
        .where(
          (item) => item is Map<String, dynamic> && item['image_url'] != null,
        )
        .map<String>((item) => item['image_url'].toString())
        .where((url) => url.isNotEmpty)
        .toList();
  }

  static int _parseCategoryId(dynamic categoryData) {
    if (categoryData is Map<String, dynamic>) {
      return _parseIntSafely(categoryData['id']);
    }
    return 0;
  }

  static String _parseCategoryName(dynamic categoryData) {
    if (categoryData is Map<String, dynamic>) {
      return categoryData['category']?.toString() ?? 'Unknown Category';
    }
    return 'Unknown Category';
  }

  static DateTime _parseDateTimeSafely(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  // Computed properties
  bool get hasValidRating => averageRating != null && averageRating! > 0;

  bool get hasImages => locationImages.isNotEmpty;

  String get formattedDistance {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  String get formattedRating {
    if (!hasValidRating) return 'No rating';
    return averageRating!.toStringAsFixed(1);
  }

  // Validation methods
  bool get isValid {
    return id > 0 &&
        placeId.isNotEmpty &&
        name.isNotEmpty &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        distance >= 0;
  }

  @override
  List<Object?> get props => [
    id,
    placeId,
    name,
    latitude,
    longitude,
    cityId,
    description,
    averageRating,
    distance,
    locationImages,
    categoryId,
    category,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'PopularPlaceModel{id: $id, name: $name, category: $category, distance: ${formattedDistance}}';
  }
}
