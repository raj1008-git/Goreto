// lib/core/services/biometric_auth_services.dart
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

import 'secure_storage_service.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final SecureStorageService _storage = SecureStorageService();

  // Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!isAvailable || !isDeviceSupported) {
        return false;
      }

      final List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();

      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get the type of biometric authentication available
  Future<String> getBiometricTypeName() async {
    try {
      final List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();

      if (availableBiometrics.contains(BiometricType.face)) {
        return 'Face ID';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return 'Fingerprint';
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        return 'Iris';
      } else if (availableBiometrics.contains(BiometricType.strong) ||
          availableBiometrics.contains(BiometricType.weak)) {
        return 'Biometric';
      }
      return 'Biometric';
    } catch (e) {
      return 'Biometric';
    }
  }

  // Authenticate using biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw Exception('Biometric authentication not available');
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please verify your identity to login',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Biometric Authentication',
            biometricHint: 'Verify your identity',
            biometricNotRecognized: 'Biometric not recognized. Try again.',
            biometricSuccess: 'Biometric authentication successful',
            cancelButton: 'Cancel',
            deviceCredentialsRequiredTitle: 'Device credentials required',
            deviceCredentialsSetupDescription:
                'Please set up device credentials',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription: 'Please set up biometric authentication',
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  // Check if biometric login is enabled for the user
  Future<bool> isBiometricLoginEnabled() async {
    try {
      final String? enabled = await _storage.read('biometric_login_enabled');
      return enabled == 'true';
    } catch (e) {
      return false;
    }
  }

  // Enable biometric login and save credentials securely
  Future<void> enableBiometricLogin(String email, String password) async {
    try {
      // Save encrypted credentials
      await _storage.write('biometric_email', email);
      await _storage.write('biometric_password', password);
      await _storage.write('biometric_login_enabled', 'true');
    } catch (e) {
      throw Exception('Failed to enable biometric login: ${e.toString()}');
    }
  }

  // Disable biometric login and clear saved credentials
  Future<void> disableBiometricLogin() async {
    try {
      await _storage.delete('biometric_email');
      await _storage.delete('biometric_password');
      await _storage.write('biometric_login_enabled', 'false');
    } catch (e) {
      throw Exception('Failed to disable biometric login: ${e.toString()}');
    }
  }

  // Get saved biometric credentials
  Future<Map<String, String>?> getBiometricCredentials() async {
    try {
      final String? email = await _storage.read('biometric_email');
      final String? password = await _storage.read('biometric_password');

      if (email != null && password != null) {
        return {'email': email, 'password': password};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Clear all biometric data (used during logout if needed)
  Future<void> clearBiometricData() async {
    try {
      await _storage.delete('biometric_email');
      await _storage.delete('biometric_password');
      await _storage.delete('biometric_login_enabled');
    } catch (e) {
      throw Exception('Failed to clear biometric data: ${e.toString()}');
    }
  }
}
