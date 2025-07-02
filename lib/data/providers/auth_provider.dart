import 'package:flutter/material.dart';
import 'package:goreto/data/datasources/remote/auth_api_service.dart';
import 'package:goreto/data/models/auth/login_response_model.dart';
import '../../../core/services/secure_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApiService _api = AuthApiService();
  final SecureStorageService _storage = SecureStorageService();

  UserModel? _user;
  UserModel? get user => _user;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.login(email, password);
      _user = response.user;

      await _storage.write('access_token', response.accessToken);
      await _storage.write('token_type', response.tokenType);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    await _storage.clear();
    notifyListeners();
  }
}
