class UserLocationResponse {
  final String message;
  final UserLocationData data;

  UserLocationResponse({required this.message, required this.data});

  factory UserLocationResponse.fromJson(Map<String, dynamic> json) {
    return UserLocationResponse(
      message: json['message'],
      data: UserLocationData.fromJson(json['data']),
    );
  }
}

class UserLocationData {
  final int id;
  final int userId;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserLocationData({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserLocationData.fromJson(Map<String, dynamic> json) {
    return UserLocationData(
      id: json['id'],
      userId: json['user_id'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
