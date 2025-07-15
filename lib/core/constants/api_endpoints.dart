class ApiEndpoints {
  static const String baseUrl = "http://192.168.254.11:8000/api";
  static const String storageBaseUrl = "http://192.168.254.11:8000/storage";

  static const String login = "$baseUrl/login";
  static const String placesByCategory = "$baseUrl/places-by-category";
  static const String userLocation = "$baseUrl/user-location";
  static const String nearbyUsers = "$baseUrl/nearby-users";
  static const String createPost = "$baseUrl/posts";
  static const String myPosts = "$baseUrl/posts/mine";

  static String imageUrl(String imagePath) => "$imagePath";
}
