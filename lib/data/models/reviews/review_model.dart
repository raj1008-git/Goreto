class ReviewModel {
  final int id;
  final String review;
  final double rating;
  final String createdAt;
  final UserModel user;

  ReviewModel({
    required this.id,
    required this.review,
    required this.rating,
    required this.createdAt,
    required this.user,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      review: json['review'],
      rating: double.parse(json['rating']),
      createdAt: json['created_at'],
      user: UserModel.fromJson(json['user']),
    );
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;

  UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'], name: json['name'], email: json['email']);
  }
}
