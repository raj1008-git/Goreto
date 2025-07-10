class ApiEndpoints {
  static const String baseUrl = "http://192.168.254.14:8000/api";
  static const String storageBaseUrl = "http://192.168.254.14:8000/storage";

  static const String login = "$baseUrl/login";
  static const String placesByCategory = "$baseUrl/places-by-category";
  static const String userLocation =
      "$baseUrl/user-location"; // Changed to use baseUrl
  static const String nearbyUsers =
      "$baseUrl/nearby-users"; // Changed to use baseUrl
  static const String createOneOnOneChat = "$baseUrl/chats/one-on-one";
  static const String sendMessage = "$baseUrl/chats/send";
  static String getChatMessages(int chatId) =>
      "$baseUrl/chats/$chatId"; // New endpoint for fetching messages

  static String imageUrl(String imagePath) => "$imagePath";

  // Pusher Constants
  static const String pusherAppId = "2018206";
  static const String pusherAppKey = "e7d5c39c702fe12df9e2";
  static const String pusherAppSecret =
      "31d4d6215ce701123594"; // Note: This might not be needed client-side for public/private channels if using authEndpoint
  static const String pusherAppCluster = "ap2";
  static const String pusherAuthEndpoint =
      "http://192.168.254.14:8000/broadcasting/auth"; // Standard Laravel Echo auth endpoint
}
