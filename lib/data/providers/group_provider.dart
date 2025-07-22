// lib/providers/group_provider.dart

import 'package:flutter/foundation.dart';

import '../datasources/remote/group_service_api.dart';
import '../models/Group/group_model.dart';

class GroupProvider with ChangeNotifier {
  final GroupApiService _apiService;

  GroupProvider(this._apiService);

  List<GroupModel> _myGroups = [];
  List<GroupModel> _latestGroups = [];
  List<GroupModel> _joinableGroups = [];

  bool _isLoadingMyGroups = false;
  bool _isLoadingLatestGroups = false;
  bool _isLoadingJoinableGroups = false;

  String? _errorMessage;

  // Getters
  List<GroupModel> get myGroups => _myGroups;
  List<GroupModel> get latestGroups => _latestGroups;
  List<GroupModel> get joinableGroups => _joinableGroups;

  bool get isLoadingMyGroups => _isLoadingMyGroups;
  bool get isLoadingLatestGroups => _isLoadingLatestGroups;
  bool get isLoadingJoinableGroups => _isLoadingJoinableGroups;

  String? get errorMessage => _errorMessage;
  // Add these properties to GroupProvider class
  List<GroupModel> _allGroups = [];
  bool _isLoadingAllGroups = false;

  List<GroupModel> get allGroups => _allGroups;
  bool get isLoadingAllGroups => _isLoadingAllGroups;

  // Add these methods
  Future<void> fetchAllGroups() async {
    _isLoadingAllGroups = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allGroups = await _apiService.getAllGroups();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingAllGroups = false;
      notifyListeners();
    }
  }

  // Future<bool> joinGroup(int groupId) async {
  //   try {
  //     final result = await _apiService.joinGroup(groupId);
  //     // Refresh both lists after successful join
  //     await fetchAllGroups();
  //     await fetchMyGroups();
  //     return result['success'] ?? false;
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //     notifyListeners();
  //     return false;
  //   }
  // }
  Future<Map<String, dynamic>> joinGroup(int groupId) async {
    try {
      final result = await _apiService.joinGroup(groupId);

      if (result['success'] == true) {
        // Successfully joined - refresh both lists
        await fetchAllGroups();
        await fetchMyGroups();
      }
      // Don't clear error message or refresh lists for "already member" case
      // This prevents the UI from showing empty state

      return result;
    } catch (e) {
      return {
        'success': false,
        'alreadyMember': false,
        'message': 'An unexpected error occurred.',
      };
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Fetch My Groups
  Future<void> fetchMyGroups() async {
    _isLoadingMyGroups = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myGroups = await _apiService.getMyGroups();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _myGroups = [];
    } finally {
      _isLoadingMyGroups = false;
      notifyListeners();
    }
  }

  // Fetch Latest Groups
  Future<void> fetchLatestGroups() async {
    _isLoadingLatestGroups = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement when API is available
      _latestGroups = [];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _latestGroups = [];
    } finally {
      _isLoadingLatestGroups = false;
      notifyListeners();
    }
  }

  // Fetch Joinable Groups
  Future<void> fetchJoinableGroups() async {
    _isLoadingJoinableGroups = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement when API is available
      _joinableGroups = [];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _joinableGroups = [];
    } finally {
      _isLoadingJoinableGroups = false;
      notifyListeners();
    }
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    await Future.wait([
      fetchMyGroups(),
      fetchLatestGroups(),
      fetchJoinableGroups(),
    ]);
  }
}
