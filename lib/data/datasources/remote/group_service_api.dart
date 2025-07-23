// lib/data/datasources/remote/group_api_service.dart

import 'package:dio/dio.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';

import '../../models/Group/group_model.dart';

class GroupApiService {
  final Dio dio;

  GroupApiService(this.dio);

  Future<List<GroupModel>> getMyGroups() async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    final response = await dio.get(
      ApiEndpoints.myGroups, // Using the constant from ApiEndpoints
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> groupsData = response.data['groups'];
      return groupsData
          .map<GroupModel>((json) => GroupModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch groups: ${response.statusMessage}');
    }
  }

  Future<Map<String, dynamic>> createGroup(String groupName) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    try {
      final response = await dio.post(
        ApiEndpoints.createGroup,
        data: {'name': groupName},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return {
        'success': true,
        'message': response.data['message'],
        'group': response.data['group'],
        'group_chat': response.data['group_chat'],
      };
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
          return {
            'success': false,
            'limitReached': true,
            'message':
                e.response?.data['message'] ??
                'Group creation limit reached. Please subscribe to create more groups.',
          };
        }
        return {
          'success': false,
          'limitReached': false,
          'message': e.response?.data['message'] ?? 'Failed to create group',
        };
      }
      return {
        'success': false,
        'limitReached': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  Future<List<GroupModel>> getAllGroups() async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    final response = await dio.get(
      ApiEndpoints
          .createGroup, // This is '/groups' endpoint for getting all groups
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['groups'];
      return data.map((json) => GroupModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch all groups: ${response.statusMessage}');
    }
  }

  // Add this method to your existing GroupApiService class

  Future<List<GroupModel>> getJoinedGroups() async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    final response = await dio.get(
      ApiEndpoints.joinedGroups,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> groupsData = response.data['groups'];
      return groupsData
          .map<GroupModel>((json) => GroupModel.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to fetch joined groups: ${response.statusMessage}',
      );
    }
  }

  // Future<Map<String, dynamic>> joinGroup(int groupId) async {
  //   final storage = SecureStorageService();
  //   final token = await storage.read('access_token');
  //
  //   if (token == null) {
  //     throw Exception('Access token not found');
  //   }
  //
  //   final response = await dio.post(
  //     '${ApiEndpoints.baseUrl}/group-join/$groupId', // Direct URL construction
  //     options: Options(
  //       headers: {
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     ),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     return {
  //       'success': true,
  //       'message': response.data['message'],
  //       'group': response.data['group'],
  //     };
  //   } else {
  //     return {
  //       'success': false,
  //       'message': response.data['message'] ?? 'Failed to join group',
  //       'group': null,
  //     };
  //   }
  // }
  Future<Map<String, dynamic>> joinGroup(int groupId) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');
    try {
      // final response = await dio.post('/group-join/$groupId');
      final response = await dio.post(
        '${ApiEndpoints.baseUrl}/group-join/$groupId', // Direct URL construction
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return {
        'success': true,
        'message': response.data['message'],
        'group': response.data['group'],
      };
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        // Handle "already a member" case
        return {
          'success': false,
          'alreadyMember': true,
          'message':
              e.response?.data['message'] ??
              'You are already a member of this group.',
        };
      }
      // Handle other errors
      return {
        'success': false,
        'alreadyMember': false,
        'message': 'Failed to join group. Please try again.',
      };
    }
  }

  // For future implementation - using the endpoints you've defined
  Future<List<GroupModel>> getLatestGroups() async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    final response = await dio.get(
      ApiEndpoints.latestGroups,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['groups'];
      return data.map((json) => GroupModel.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch latest groups: ${response.statusMessage}',
      );
    }
  }

  Future<List<GroupModel>> getJoinableGroups() async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    final response = await dio.get(
      ApiEndpoints.joinableGroups,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['groups'];
      return data.map((json) => GroupModel.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch joinable groups: ${response.statusMessage}',
      );
    }
  }
}
