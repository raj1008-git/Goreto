class ApiEndpoints {
  static const String baseUrl = "http://10.0.2.2:8000/api";
  static const String storageBaseUrl = "http://10.0.2.2:8000/storage";

  static const String login = "$baseUrl/login";
  static const String placesByCategory = "$baseUrl/places-by-category";
  static const String userLocation = "$baseUrl/user-location";
  static const String nearbyUsers = "$baseUrl/nearby-users";
  static const String createPost = "$baseUrl/posts";
  static const String myPosts = "$baseUrl/posts/mine";
  static const String posts = '$baseUrl/posts';
  static const String tapbookmarks = '$baseUrl/post-bookmarks';
  static const String postBookmarks = '$baseUrl/post-bookmarks';

  static String imageUrl(String imagePath) => "$imagePath";
}
