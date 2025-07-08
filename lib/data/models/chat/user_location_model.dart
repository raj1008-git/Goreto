// user_location_model.dart
class UserLocationResponse {
  final String message;
  final UserLocation data;

  UserLocationResponse({required this.message, required this.data});

  factory UserLocationResponse.fromJson(Map<String, dynamic> json) =>
      UserLocationResponse(
        message: json['message'],
        data: UserLocation.fromJson(json['data']),
      );
}

class UserLocation {
  final int id;
  final int userId;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserLocation({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) => UserLocation(
    id: json['id'],
    userId: json['user_id'],
    latitude: json['latitude'].toDouble(),
    longitude: json['longitude'].toDouble(),
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );
}
