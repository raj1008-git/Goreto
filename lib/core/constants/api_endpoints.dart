class ApiEndpoints {
  static const String baseUrl = "http://192.168.254.13:8000/api";
  static const String storageBaseUrl = "http://192.168.254.13:8000/storage";

  static const String login = "$baseUrl/login";
  static const String placesByCategory = "$baseUrl/places-by-category";
  static const String userLocation = "/user-location";
  static const String nearbyUsers = "/nearby-users";

  static String imageUrl(String imagePath) => "$imagePath";
}
