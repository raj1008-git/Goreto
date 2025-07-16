class PostReviewModel {
  final int id;
  final String review;
  final String userName;
  final DateTime createdAt;

  PostReviewModel({
    required this.id,
    required this.review,
    required this.userName,
    required this.createdAt,
  });

  factory PostReviewModel.fromJson(Map<String, dynamic> json) {
    return PostReviewModel(
      id: json['id'],
      review: json['review'],
      userName: json['user']['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
