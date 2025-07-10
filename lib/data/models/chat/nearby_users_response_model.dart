class NearbyUsersResponse {
  final String message;
  final int count;
  final List<NearbyUser> data;

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
          .map((userJson) => NearbyUser.fromJson(userJson))
          .toList(),
    );
  }
}

class NearbyUser {
  final int id;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int countryId;
  final double distance;

  NearbyUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.countryId,
    required this.distance,
  });

  factory NearbyUser.fromJson(Map<String, dynamic> json) {
    return NearbyUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      countryId: json['country_id'],
      distance: (json['distance'] as num).toDouble(),
    );
  }
}
