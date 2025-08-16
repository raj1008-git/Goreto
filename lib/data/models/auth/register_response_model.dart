// lib/data/models/auth/register_response_model.dart
class RegisterResponse {
  final String message;
  final RegisterUserModel user;

  RegisterResponse({required this.message, required this.user});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'],
      user: RegisterUserModel.fromJson(json['user']),
    );
  }
}

class RegisterUserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String country;

  RegisterUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.country,
  });

  factory RegisterUserModel.fromJson(Map<String, dynamic> json) {
    return RegisterUserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'country': country,
    };
  }
}
