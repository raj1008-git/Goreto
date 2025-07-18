import 'package:flutter/material.dart';

import '../datasources/remote/group_service_api.dart';
import '../models/Group/group_model.dart';

class GroupProvider with ChangeNotifier {
  final GroupService service;
  GroupModel? _createdGroup;
  bool _isCreating = false;

  GroupProvider(this.service);

  GroupModel? get createdGroup => _createdGroup;
  bool get isCreating => _isCreating;

  Future<GroupModel> createGroup(String name) async {
    debugPrint("📤 [GroupProvider] Sending createGroup request...");
    final response = await service.createGroup(name);
    debugPrint(
      "✅ [GroupProvider] Group created: ${response.name} (ID: ${response.id})",
    );

    _createdGroup = response;
    notifyListeners();
    return response;
  }
}
