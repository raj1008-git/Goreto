import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../models/Group/group_model.dart';

GroupModel _parseGroupResponse(Map<String, dynamic> json) {
  return GroupModel.fromJson(json['group']);
}

class GroupService {
  final Dio dio;

  GroupService(this.dio);

  Future<GroupModel> createGroup(String name) async {
    debugPrint("🟡 [GroupService] Creating group with name: $name");

    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('❌ Access token not found');
    }

    final response = await dio.post(
      ApiEndpoints.createGroup,
      data: {"name": name},
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    debugPrint(
      "🟢 [GroupService] Response: ${response.statusCode} -> ${response.data}",
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return compute<Map<String, dynamic>, GroupModel>(
        _parseGroupResponse,
        response.data as Map<String, dynamic>,
      );
    } else {
      throw Exception("❌ Failed to create group - ${response.statusCode}");
    }
  }
}
