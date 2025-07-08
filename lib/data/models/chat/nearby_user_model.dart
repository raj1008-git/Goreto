// nearby_user_model.dart
class NearbyUserResponse {
  final String message;
  final int count;
  final List<NearbyUser> data;

  NearbyUserResponse({
    required this.message,
    required this.count,
    required this.data,
  });

  factory NearbyUserResponse.fromJson(Map<String, dynamic> json) =>
      NearbyUserResponse(
        message: json['message'],
        count: json['count'],
        data: List<NearbyUser>.from(
          json['data'].map((x) => NearbyUser.fromJson(x)),
        ),
      );
}

class NearbyUser {
  final int id;
  final String name;
  final String email;
  final double distance;

  NearbyUser({
    required this.id,
    required this.name,
    required this.email,
    required this.distance,
  });

  factory NearbyUser.fromJson(Map<String, dynamic> json) => NearbyUser(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    distance: json['distance'].toDouble(),
  );
}
