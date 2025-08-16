// lib/data/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:goreto/data/datasources/remote/auth_api_service.dart';
import 'package:goreto/data/models/auth/login_response_model.dart';
import 'package:goreto/data/models/auth/register_response_model.dart';

import '../../../core/services/secure_storage_service.dart';
import '../../core/services/biometric_auth_services.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApiService _api = AuthApiService();
  final SecureStorageService _storage = SecureStorageService();
  final BiometricService _biometricService = BiometricService();

  UserModel? _user;
  UserModel? get user => _user;

  RegisterUserModel? _registeredUser;
  RegisterUserModel? get registeredUser => _registeredUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isBiometricAvailable = false;
  bool get isBiometricAvailable => _isBiometricAvailable;

  bool _isBiometricEnabled = false;
  bool get isBiometricEnabled => _isBiometricEnabled;

  String _biometricTypeName = 'Biometric';
  String get biometricTypeName => _biometricTypeName;

  // Initialize biometric status
  Future<void> initializeBiometric() async {
    _isBiometricAvailable = await _biometricService.isBiometricAvailable();
    _isBiometricEnabled = await _biometricService.isBiometricLoginEnabled();
    _biometricTypeName = await _biometricService.getBiometricTypeName();
    notifyListeners();
  }

  // Registration
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String country,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        country: country,
      );

      _registeredUser = response.user;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Email verification
  Future<void> verifyEmail(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _api.verifyEmail(token);
      // Clear the registered user after successful verification
      _registeredUser = null;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Regular login
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.login(email, password);
      _user = response.user;

      await _storage.write('access_token', response.accessToken);
      await _storage.write('token_type', response.tokenType);
      await _storage.write('user_id', response.user.id.toString());
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Biometric login
  Future<void> loginWithBiometric() async {
    if (!_isBiometricAvailable || !_isBiometricEnabled) {
      throw Exception('Biometric authentication not available or not enabled');
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Authenticate with biometric
      final isAuthenticated = await _biometricService
          .authenticateWithBiometrics();

      if (!isAuthenticated) {
        throw Exception('Biometric authentication failed');
      }

      // Get saved credentials
      final credentials = await _biometricService.getBiometricCredentials();
      if (credentials == null) {
        throw Exception('No saved credentials found');
      }

      // Login with saved credentials
      await login(credentials['email']!, credentials['password']!);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Enable biometric login after successful regular login
  Future<void> enableBiometricLogin(String email, String password) async {
    if (!_isBiometricAvailable) {
      throw Exception('Biometric authentication not available');
    }

    // Test biometric authentication first
    final isAuthenticated = await _biometricService
        .authenticateWithBiometrics();
    if (!isAuthenticated) {
      throw Exception('Biometric authentication setup failed');
    }

    await _biometricService.enableBiometricLogin(email, password);
    _isBiometricEnabled = true;
    notifyListeners();
  }

  // Disable biometric login
  Future<void> disableBiometricLogin() async {
    await _biometricService.disableBiometricLogin();
    _isBiometricEnabled = false;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    try {
      _user = null;
      _registeredUser = null;
      await _storage.clear();
      // Note: We keep biometric settings even after logout
      // so user doesn't need to set it up again
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to logout: ${e.toString()}');
    }
  }

  // Check if user is logged in
  Future<bool> checkAuthStatus() async {
    final token = await _storage.read('access_token');
    return token != null;
  }
}
