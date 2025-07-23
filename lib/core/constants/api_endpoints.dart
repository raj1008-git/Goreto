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
// http://110.34.1.123:8080
class ApiEndpoints {
  static const String ip = "110.34.1.123";
  static const String baseUrl = "http://110.34.1.123:8080/api";
  static const String storageBaseUrl = "http://110.34.1.123:8080/storage";

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
  static const String activityStatus = "$baseUrl/activity-status";
  static const String myGroups = "$baseUrl/my-groups";
  static const String latestGroups = "$baseUrl/latest-groups"; // For future use
  static const String joinableGroups = "$baseUrl/joinable-groups";
  static const String categories = "$baseUrl/categories";
  // static const String popularPlaces = "$baseUrl/places/popular";

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
