// lib/data/models/category/category_model.dart

class CategoryModel {
  final int id;
  final String category;
  final String createdAt;
  final String updatedAt;

  CategoryModel({
    required this.id,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      category: json['category'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class CategoryResponse {
  final String message;
  final CategoryPaginationData data;

  CategoryResponse({required this.message, required this.data});

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      message: json['message'],
      data: CategoryPaginationData.fromJson(json['data']),
    );
  }
}

class CategoryPaginationData {
  final int currentPage;
  final List<CategoryModel> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  CategoryPaginationData({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory CategoryPaginationData.fromJson(Map<String, dynamic> json) {
    return CategoryPaginationData(
      currentPage: json['current_page'],
      data: (json['data'] as List)
          .map((category) => CategoryModel.fromJson(category))
          .toList(),
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'],
    );
  }
}
