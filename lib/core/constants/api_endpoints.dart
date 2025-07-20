// class ApiEndpoints {
//   static const String baseUrl = "http://192.168.254.10:8000/api";
//   static const String storageBaseUrl = "http://192.168.254.10:8000/storage";
//
//   static const String login = "$baseUrl/login";
//   static const String placesByCategory = "$baseUrl/places-by-category";
//   static const String userLocation = "$baseUrl/user-location";
//   static const String nearbyUsers = "$baseUrl/nearby-users";
//   static const String createPost = "$baseUrl/posts";
//   static const String myPosts = "$baseUrl/posts/mine";
//   static const String posts = '$baseUrl/posts';
//   static const String tapbookmarks = '$baseUrl/post-bookmarks';
//   static const String postBookmarks = '$baseUrl/post-bookmarks';
//   static const String createGroup = "$baseUrl/groups";
//
//   // Profile endpoints
//   static const String profilePicture = "$baseUrl/profile-picture";
//   static const String updateProfilePicture = "$baseUrl/profile-picture/update";
//   static const String changePassword = "$baseUrl/change-password";
//
//   static String imageUrl(String imagePath) => "$imagePath";
// }
// api_endpoints.dart
class ApiEndpoints {
  static const String ip = "10.20.0.107";
  static const String baseUrl = "http://10.20.0.107:8000/api";
  static const String storageBaseUrl = "http://10.20.0.107:8000/storage";

  static const String login = "$baseUrl/login";
  static const String placesByCategory = "$baseUrl/places-by-category";
  static const String userLocation = "$baseUrl/user-location";
  static const String nearbyUsers = "$baseUrl/nearby-users";
  static const String createPost = "$baseUrl/posts";
  static const String myPosts = "$baseUrl/posts/mine";
  static const String posts = '$baseUrl/posts';
  static const String tapbookmarks = '$baseUrl/post-bookmarks';
  static const String postBookmarks = '$baseUrl/post-bookmarks';
  static const String createGroup = "$baseUrl/groups";

  // Like endpoints
  static const String postsLike = '$baseUrl/posts-like';

  // Comment endpoints
  static const String postReviews = '$baseUrl/post-reviews';

  // Profile endpoints
  static const String profilePicture = "$baseUrl/profile-picture";
  static const String updateProfilePicture = "$baseUrl/profile-picture/update";
  static const String changePassword = "$baseUrl/change-password";

  static String imageUrl(String imagePath) => "$imagePath";

  // Helper methods
  static String postLikeUrl(int postId) => "$postsLike/$postId";
  static String postCommentsUrl(int postId) => "$postReviews/$postId";
}
