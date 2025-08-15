// lib/presentation/auth/widgets/biometric_login_button.dart
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/constants/appColors.dart';

class BiometricLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final List<BiometricType> availableBiometrics;
  final String biometricTypeName;

  const BiometricLoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.availableBiometrics = const [],
    this.biometricTypeName = 'Biometric',
  });

  IconData _getBiometricIcon() {
    if (availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      return Icons.remove_red_eye;
    } else {
      return Icons.fingerprint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Divider with "OR" text
          Row(
            children: [
              Expanded(
                child: Container(height: 1, color: Colors.grey.shade300),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Container(height: 1, color: Colors.grey.shade300),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Biometric login button
          GestureDetector(
            onTap: isLoading ? null : onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  : Icon(
                      _getBiometricIcon(),
                      size: 30,
                      color: AppColors.primary,
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // Biometric type text
          Text(
            'Login with $biometricTypeName',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Alternative floating biometric button (can be used instead of the above)
class FloatingBiometricButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final List<BiometricType> availableBiometrics;

  const FloatingBiometricButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.availableBiometrics = const [],
  });

  IconData _getBiometricIcon() {
    if (availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      return Icons.remove_red_eye;
    } else {
      return Icons.security;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 24,
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                )
              : Icon(_getBiometricIcon(), size: 22, color: AppColors.primary),
        ),
      ),
    );
  }
}
