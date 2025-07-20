// // like_comment_api_service.dart
// import 'package:dio/dio.dart';
// import 'package:goreto/core/constants/api_endpoints.dart';
// import 'package:goreto/core/services/secure_storage_service.dart';
//
// import '../../models/post/comment_model.dart';
// // Import your comment models
//
// class LikeCommentApiService {
//   final Dio dio;
//
//   LikeCommentApiService(this.dio);
//
//   // Like/Unlike post
//   Future<PostLikeResponse> toggleLike(int postId) async {
//     final storage = SecureStorageService();
//     final token = await storage.read('access_token');
//
//     if (token == null) {
//       throw Exception('Access token not found. Please login again.');
//     }
//
//     try {
//       final response = await dio.post(
//         '${ApiEndpoints.baseUrl}/posts-like/$postId',
//         options: Options(
//           headers: {
//             'Accept': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return PostLikeResponse.fromJson(response.data);
//       } else {
//         throw Exception('Failed to toggle like: ${response.statusMessage}');
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 401) {
//         throw Exception('Unauthorized. Please login again.');
//       } else if (e.response?.statusCode == 403) {
//         throw Exception('Access forbidden.');
//       } else if (e.response?.statusCode == 404) {
//         throw Exception('Post not found.');
//       } else if (e.response?.statusCode == 500) {
//         throw Exception('Server error. Please try again.');
//       } else {
//         throw Exception('Network error: ${e.message}');
//       }
//     } catch (e) {
//       throw Exception('Failed to toggle like: $e');
//     }
//   }
//
//   // Get post likes
//   Future<LikeResponse> getPostLikes(int postId) async {
//     final storage = SecureStorageService();
//     final token = await storage.read('access_token');
//
//     if (token == null) {
//       throw Exception('Access token not found. Please login again.');
//     }
//
//     try {
//       final response = await dio.get(
//         '${ApiEndpoints.baseUrl}/posts-like/$postId',
//         options: Options(
//           headers: {
//             'Accept': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         return LikeResponse.fromJson(response.data);
//       } else {
//         throw Exception('Failed to fetch likes: ${response.statusMessage}');
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 401) {
//         throw Exception('Unauthorized. Please login again.');
//       } else if (e.response?.statusCode == 404) {
//         throw Exception('Post not found.');
//       } else {
//         throw Exception('Network error: ${e.message}');
//       }
//     } catch (e) {
//       throw Exception('Failed to fetch likes: $e');
//     }
//   }
//
//   // Add comment to post
//   Future<CommentModel> addComment(int postId, String review) async {
//     final storage = SecureStorageService();
//     final token = await storage.read('access_token');
//
//     if (token == null) {
//       throw Exception('Access token not found. Please login again.');
//     }
//
//     try {
//       final response = await dio.post(
//         '${ApiEndpoints.baseUrl}/post-reviews/$postId',
//         data: {'review': review},
//         options: Options(
//           headers: {
//             'Accept': 'application/json',
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return CommentModel.fromJson(response.data['review']);
//       } else {
//         throw Exception('Failed to add comment: ${response.statusMessage}');
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 401) {
//         throw Exception('Unauthorized. Please login again.');
//       } else if (e.response?.statusCode == 403) {
//         throw Exception('Access forbidden.');
//       } else if (e.response?.statusCode == 404) {
//         throw Exception('Post not found.');
//       } else if (e.response?.statusCode == 500) {
//         throw Exception('Server error. Please try again.');
//       } else {
//         throw Exception('Network error: ${e.message}');
//       }
//     } catch (e) {
//       throw Exception('Failed to add comment: $e');
//     }
//   }
//
//   // Get post comments
//   Future<CommentsResponse> getPostComments(int postId, {int page = 1}) async {
//     final storage = SecureStorageService();
//     final token = await storage.read('access_token');
//
//     if (token == null) {
//       throw Exception('Access token not found. Please login again.');
//     }
//
//     try {
//       final response = await dio.get(
//         '${ApiEndpoints.baseUrl}/post-reviews/$postId',
//         queryParameters: {'page': page},
//         options: Options(
//           headers: {
//             'Accept': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         return CommentsResponse.fromJson(response.data);
//       } else {
//         throw Exception('Failed to fetch comments: ${response.statusMessage}');
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 401) {
//         throw Exception('Unauthorized. Please login again.');
//       } else if (e.response?.statusCode == 404) {
//         throw Exception('Post not found.');
//       } else {
//         throw Exception('Network error: ${e.message}');
//       }
//     } catch (e) {
//       throw Exception('Failed to fetch comments: $e');
//     }
//   }
// }
// like_comment_api_service.dart
import 'package:dio/dio.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';

import '../../models/post/comment_model.dart';

class LikeCommentApiService {
  final Dio dio;

  LikeCommentApiService(this.dio);

  // Like/Unlike post
  Future<PostLikeResponse> toggleLike(int postId) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found. Please login again.');
    }

    try {
      final response = await dio.post(
        '${ApiEndpoints.baseUrl}/posts-like/$postId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PostLikeResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to toggle like: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access forbidden.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Post not found.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  // Get post likes
  Future<LikeResponse> getPostLikes(int postId) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found. Please login again.');
    }

    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/posts-like/$postId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return LikeResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch likes: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Post not found.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch likes: $e');
    }
  }

  // Add comment to post
  Future<CommentModel> addComment(int postId, String review) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found. Please login again.');
    }

    try {
      final response = await dio.post(
        '${ApiEndpoints.baseUrl}/post-reviews/$postId',
        data: {'review': review},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // The POST response doesn't include the user details,
        // so we need to fetch them separately or create a temporary comment
        final reviewData = response.data['review'];

        // Create a temporary comment model with basic info
        // The user info will be fetched when we refresh comments
        return CommentModel(
          id: _parseToInt(reviewData['id']),
          review: reviewData['review'] ?? '',
          userId: _parseToInt(reviewData['user_id']),
          postId: _parseToInt(reviewData['post_id']),
          createdAt: DateTime.parse(reviewData['created_at']),
          updatedAt: DateTime.parse(reviewData['updated_at']),
          user: CommentUser(
            id: _parseToInt(reviewData['user_id']),
            name:
                'You', // Temporary name - will be updated when comments are refreshed
            email: '', // Temporary email
            profilePictureUrl: null,
          ),
        );
      } else {
        throw Exception('Failed to add comment: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access forbidden.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Post not found.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // Helper method to safely parse int values
  static int _parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    return 0; // Default fallback
  }

  // Get post comments
  Future<CommentsResponse> getPostComments(int postId, {int page = 1}) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found. Please login again.');
    }

    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/post-reviews/$postId',
        queryParameters: {'page': page},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return CommentsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch comments: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Post not found.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch comments: $e');
    }
  }
}
