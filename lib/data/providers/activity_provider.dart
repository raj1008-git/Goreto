// lib/providers/activity_provider.dart

import 'package:flutter/material.dart';

import '../datasources/remote/activity_api_service.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityApiService _apiService;
  bool _activityStatus = false;
  bool _isLoading = false;
  String? _error;

  ActivityProvider(this._apiService);

  bool get activityStatus => _activityStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> toggleActivityStatus() async {
    if (_isLoading) return; // Prevent multiple simultaneous calls

    // Store the previous state for potential rollback
    final previousStatus = _activityStatus;

    // Update UI immediately for better responsiveness
    _activityStatus = !_activityStatus;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.updateActivityStatus(_activityStatus);

      // Ensure the state matches the server response
      final serverStatus = response['activity_status'];
      if (serverStatus != null) {
        _activityStatus = serverStatus;
      }

      _isLoading = false;
      _error = null;
      notifyListeners();

      debugPrint('Activity status updated to: $_activityStatus');
    } catch (e) {
      // Revert the status on error
      _activityStatus = previousStatus;
      _error = e.toString();
      _isLoading = false;
      notifyListeners();

      // Show error to user
      debugPrint('Error updating activity status: $e');
      rethrow; // Re-throw so UI can handle the error if needed
    }
  }

  Future<void> loadActivityStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getActivityStatus();
      _activityStatus = response['activity_status'] ?? false;
      _isLoading = false;
      _error = null;
      notifyListeners();

      debugPrint('Activity status loaded: $_activityStatus');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading activity status: $e');
    }
  }

  void setActivityStatus(bool status) {
    if (_activityStatus != status) {
      _activityStatus = status;
      notifyListeners();
    }
  }

  // Method to clear any errors
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
