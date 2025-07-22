// lib/data/models/Group/group_model.dart

class GroupModel {
  final int id;
  final String name;
  final String createdBy;
  final int groupChatId;
  final String createdAt;
  final String updatedAt;
  final String? profilePicture;
  final String? profilePictureUrl;
  final List<UserGroupModel> userGroups;
  final List<dynamic> groupLocations;

  GroupModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.groupChatId,
    required this.createdAt,
    required this.updatedAt,
    this.profilePicture,
    this.profilePictureUrl,
    required this.userGroups,
    required this.groupLocations,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      name: json['name'],
      createdBy: json['created_by'],
      groupChatId: json['group_chat_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      profilePicture: json['profile_picture'],
      profilePictureUrl: json['profile_picture_url'],
      userGroups: (json['user_groups'] as List)
          .map((userGroup) => UserGroupModel.fromJson(userGroup))
          .toList(),
      groupLocations: json['group_locations'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_by': createdBy,
      'group_chat_id': groupChatId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'profile_picture': profilePicture,
      'profile_picture_url': profilePictureUrl,
      'user_groups': userGroups.map((userGroup) => userGroup.toJson()).toList(),
      'group_locations': groupLocations,
    };
  }
}

class UserGroupModel {
  final int id;
  final String memberRole;
  final int userId;
  final int groupId;
  final String createdAt;
  final String updatedAt;
  final UserModel user;

  UserGroupModel({
    required this.id,
    required this.memberRole,
    required this.userId,
    required this.groupId,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory UserGroupModel.fromJson(Map<String, dynamic> json) {
    return UserGroupModel(
      id: json['id'],
      memberRole: json['member_role'],
      userId: json['user_id'],
      groupId: json['group_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_role': memberRole,
      'user_id': userId,
      'group_id': groupId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user.toJson(),
    };
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? emailVerificationToken;
  final String createdAt;
  final String updatedAt;
  final int countryId;
  final int roleId;
  final int activityStatus;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.emailVerificationToken,
    required this.createdAt,
    required this.updatedAt,
    required this.countryId,
    required this.roleId,
    required this.activityStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      emailVerificationToken: json['email_verification_token'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      countryId: json['country_id'],
      roleId: json['role_id'],
      activityStatus: json['activity_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'email_verification_token': emailVerificationToken,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'country_id': countryId,
      'role_id': roleId,
      'activity_status': activityStatus,
    };
  }
}
