// lib/data/models/user/nearby_user_model.dart

class NearbyUserModel {
  final int id;
  final String name;
  final String email;
  final String createdAt;
  final String updatedAt;
  final int countryId;
  final double distance;

  NearbyUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.countryId,
    required this.distance,
  });

  factory NearbyUserModel.fromJson(Map<String, dynamic> json) {
    return NearbyUserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      countryId: json['country_id'],
      distance: json['distance'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'country_id': countryId,
      'distance': distance,
    };
  }

  // Helper method to format distance
  String get formattedDistance {
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }
}

class NearbyUsersResponse {
  final String message;
  final int count;
  final List<NearbyUserModel> data;

  NearbyUsersResponse({
    required this.message,
    required this.count,
    required this.data,
  });

  factory NearbyUsersResponse.fromJson(Map<String, dynamic> json) {
    return NearbyUsersResponse(
      message: json['message'],
      count: json['count'],
      data: (json['data'] as List)
          .map((user) => NearbyUserModel.fromJson(user))
          .toList(),
    );
  }
}
