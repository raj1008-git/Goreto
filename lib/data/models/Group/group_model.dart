class GroupModel {
  final int id;
  final String name;
  final int createdBy;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      name: json['name'],
      createdBy: int.parse(json['created_by'].toString()),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
