// // lib/providers/group_provider.dart
//
// import 'package:flutter/foundation.dart';
//
// import '../datasources/remote/group_service_api.dart';
// import '../models/Group/group_model.dart';
//
// class GroupProvider with ChangeNotifier {
//   final GroupApiService _apiService;
//
//   GroupProvider(this._apiService);
//
//   List<GroupModel> _myGroups = [];
//   List<GroupModel> _latestGroups = [];
//   List<GroupModel> _joinableGroups = [];
//   // Add these new properties
//   List<GroupModel> _joinedGroups = [];
//   bool _isLoadingJoinedGroups = false;
//
//   // Add these getters
//   List<GroupModel> get joinedGroups => _joinedGroups;
//   bool get isLoadingJoinedGroups => _isLoadingJoinedGroups;
//   bool _isLoadingMyGroups = false;
//   bool _isLoadingLatestGroups = false;
//   bool _isLoadingJoinableGroups = false;
//
//   String? _errorMessage;
//
//   // Getters
//   List<GroupModel> get myGroups => _myGroups;
//   List<GroupModel> get latestGroups => _latestGroups;
//   List<GroupModel> get joinableGroups => _joinableGroups;
//
//   bool get isLoadingMyGroups => _isLoadingMyGroups;
//   bool get isLoadingLatestGroups => _isLoadingLatestGroups;
//   bool get isLoadingJoinableGroups => _isLoadingJoinableGroups;
//
//   String? get errorMessage => _errorMessage;
//   // Add these properties to GroupProvider class
//   List<GroupModel> _allGroups = [];
//   bool _isLoadingAllGroups = false;
//
//   List<GroupModel> get allGroups => _allGroups;
//   bool get isLoadingAllGroups => _isLoadingAllGroups;
//
//   // Add these methods
//   Future<void> fetchAllGroups() async {
//     _isLoadingAllGroups = true;
//     _errorMessage = null;
//     notifyListeners();
//
//     try {
//       _allGroups = await _apiService.getAllGroups();
//     } catch (e) {
//       _errorMessage = e.toString();
//     } finally {
//       _isLoadingAllGroups = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> fetchJoinedGroups() async {
//     _isLoadingJoinedGroups = true;
//     _errorMessage = null;
//     notifyListeners();
//
//     try {
//       _joinedGroups = await _apiService.getJoinedGroups();
//       _errorMessage = null;
//     } catch (e) {
//       _errorMessage = e.toString();
//       _joinedGroups = [];
//     } finally {
//       _isLoadingJoinedGroups = false;
//       notifyListeners();
//     }
//   }
//
//   Future<Map<String, dynamic>> joinGroup(int groupId) async {
//     try {
//       final result = await _apiService.joinGroup(groupId);
//
//       if (result['success'] == true) {
//         // Successfully joined - refresh all lists including joined groups
//         await fetchAllGroups();
//         await fetchMyGroups();
//         await fetchJoinedGroups(); // Add this line
//       }
//
//       return result;
//     } catch (e) {
//       return {
//         'success': false,
//         'alreadyMember': false,
//         'message': 'An unexpected error occurred.',
//       };
//     }
//   }
//
//   // Clear error
//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }
//
//   // Fetch My Groups
//   Future<void> fetchMyGroups() async {
//     _isLoadingMyGroups = true;
//     _errorMessage = null;
//     notifyListeners();
//
//     try {
//       _myGroups = await _apiService.getMyGroups();
//       _errorMessage = null;
//     } catch (e) {
//       _errorMessage = e.toString();
//       _myGroups = [];
//     } finally {
//       _isLoadingMyGroups = false;
//       notifyListeners();
//     }
//   }
//
//   // Fetch Latest Groups
//   Future<void> fetchLatestGroups() async {
//     _isLoadingLatestGroups = true;
//     _errorMessage = null;
//     notifyListeners();
//
//     try {
//       // TODO: Implement when API is available
//       _latestGroups = [];
//       _errorMessage = null;
//     } catch (e) {
//       _errorMessage = e.toString();
//       _latestGroups = [];
//     } finally {
//       _isLoadingLatestGroups = false;
//       notifyListeners();
//     }
//   }
//
//   // Fetch Joinable Groups
//   Future<void> fetchJoinableGroups() async {
//     _isLoadingJoinableGroups = true;
//     _errorMessage = null;
//     notifyListeners();
//
//     try {
//       // TODO: Implement when API is available
//       _joinableGroups = [];
//       _errorMessage = null;
//     } catch (e) {
//       _errorMessage = e.toString();
//       _joinableGroups = [];
//     } finally {
//       _isLoadingJoinableGroups = false;
//       notifyListeners();
//     }
//   }
//
//   Future<Map<String, dynamic>> createGroup(String groupName) async {
//     try {
//       final result = await _apiService.createGroup(groupName);
//
//       if (result['success'] == true) {
//         // Refresh all group lists after successful creation
//         await fetchMyGroups();
//         await fetchAllGroups();
//         await fetchJoinedGroups();
//       }
//
//       return result;
//     } catch (e) {
//       return {
//         'success': false,
//         'limitReached': false,
//         'message': 'An unexpected error occurred',
//       };
//     }
//   }
//
//   // Refresh all data
//   Future<void> refreshAllData() async {
//     await Future.wait([
//       fetchMyGroups(),
//       fetchLatestGroups(),
//       fetchJoinableGroups(),
//       fetchJoinedGroups(), // Add this line
//     ]);
//   }
// }
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../datasources/remote/group_service_api.dart';
import '../models/Group/group_model.dart';

class GroupProvider with ChangeNotifier {
  final GroupApiService _apiService;

  GroupProvider(this._apiService);

  List<GroupModel> _myGroups = [];
  List<GroupModel> _latestGroups = [];
  List<GroupModel> _joinableGroups = [];
  List<GroupModel> _joinedGroups = [];
  List<GroupModel> _allGroups = [];

  bool _isLoadingMyGroups = false;
  bool _isLoadingLatestGroups = false;
  bool _isLoadingJoinableGroups = false;
  bool _isLoadingJoinedGroups = false;
  bool _isLoadingAllGroups = false;

  String? _errorMessage;

  // Getters
  List<GroupModel> get myGroups => _myGroups;
  List<GroupModel> get latestGroups => _latestGroups;
  List<GroupModel> get joinableGroups => _joinableGroups;
  List<GroupModel> get joinedGroups => _joinedGroups;
  List<GroupModel> get allGroups => _allGroups;

  bool get isLoadingMyGroups => _isLoadingMyGroups;
  bool get isLoadingLatestGroups => _isLoadingLatestGroups;
  bool get isLoadingJoinableGroups => _isLoadingJoinableGroups;
  bool get isLoadingJoinedGroups => _isLoadingJoinedGroups;
  bool get isLoadingAllGroups => _isLoadingAllGroups;

  String? get errorMessage => _errorMessage;

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

  Future<void> fetchJoinedGroups() async {
    _isLoadingJoinedGroups = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _joinedGroups = await _apiService.getJoinedGroups();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _joinedGroups = [];
    } finally {
      _isLoadingJoinedGroups = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> joinGroup(int groupId) async {
    try {
      final result = await _apiService.joinGroup(groupId);

      if (result['success'] == true) {
        await fetchAllGroups();
        await fetchMyGroups();
        await fetchJoinedGroups();
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'alreadyMember': false,
        'message': 'An unexpected error occurred.',
      };
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

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

  Future<void> fetchLatestGroups() async {
    _isLoadingLatestGroups = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _latestGroups = await _apiService.getLatestGroups();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _latestGroups = [];
    } finally {
      _isLoadingLatestGroups = false;
      notifyListeners();
    }
  }

  Future<void> fetchJoinableGroups() async {
    _isLoadingJoinableGroups = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _joinableGroups = await _apiService.getJoinableGroups();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _joinableGroups = [];
    } finally {
      _isLoadingJoinableGroups = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createGroup(
    String groupName, {
    File? profilePicture,
  }) async {
    try {
      final result = await _apiService.createGroup(
        groupName,
        profilePicture: profilePicture,
      );

      if (result['success'] == true) {
        await fetchMyGroups();
        await fetchAllGroups();
        await fetchJoinedGroups();
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'limitReached': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  Future<void> refreshAllData() async {
    await Future.wait([
      fetchMyGroups(),
      fetchLatestGroups(),
      fetchJoinableGroups(),
      fetchJoinedGroups(),
    ]);
  }
}
