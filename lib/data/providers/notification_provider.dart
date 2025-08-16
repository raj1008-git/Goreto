// lib/data/providers/notification_provider.dart
import 'package:flutter/foundation.dart';

import '../datasources/remote/notification_api_service.dart';
import '../models/notification/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationApiService _apiService;

  NotificationProvider(this._apiService);

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.fetchNotifications();
      _notifications = response.data;
      _unreadCount = response
          .total; // You can modify this logic based on read/unread status
      notifyListeners();
    } catch (e) {
      print('Error in NotificationProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void markAsRead() {
    _unreadCount = 0;
    notifyListeners();
  }
}
