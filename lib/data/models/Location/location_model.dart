// lib/data/models/location/location_model.dart

class LocationModel {
  final int id;
  final int userId;
  final double latitude;
  final double longitude;
  final String createdAt;
  final String updatedAt;

  LocationModel({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      userId: json['user_id'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class LocationResponse {
  final String message;
  final LocationModel data;

  LocationResponse({required this.message, required this.data});

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      message: json['message'],
      data: LocationModel.fromJson(json['data']),
    );
  }
}
