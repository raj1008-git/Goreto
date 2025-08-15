// lib/presentation/auth/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:goreto/core/utils/app_loader.dart';
import 'package:goreto/core/utils/snackbar_helper.dart';
import 'package:goreto/data/providers/auth_provider.dart';
import 'package:goreto/routes/app_routes.dart';
import 'package:local_auth/local_auth.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/appColors.dart';
import '../../../core/services/login_count_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'biometric_auth_widget.dart';

class AuthScreen extends StatefulWidget {
  final bool isInitiallyLogin;
  const AuthScreen({super.key, this.isInitiallyLogin = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool isLogin;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool showBiometricSetup = false;
  List<BiometricType> availableBiometrics = [];

  final LoginCountService _loginCountService = LoginCountService();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    isLogin = widget.isInitiallyLogin;
    _initializeBiometric();
  }

  Future<void> _initializeBiometric() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initializeBiometric();

    if (authProvider.isBiometricAvailable) {
      final LocalAuthentication localAuth = LocalAuthentication();
      availableBiometrics = await localAuth.getAvailableBiometrics();
    }

    if (mounted) setState(() {});
  }

  Future<void> _handleBiometricLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.loginWithBiometric();
      if (!context.mounted) return;

      final loginCount = await _loginCountService.incrementLoginCount();

      SnackbarHelper.show(
        context,
        "Welcome back! Logged in with ${authProvider.biometricTypeName} (Login #$loginCount)",
      );

      Navigator.pushReplacement(
        context,
        PageTransition(
          child: AppRoutes.getPage(AppRoutes.mainNavigation),
          type: PageTransitionType.scale,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        ),
      );
    } catch (e) {
      SnackbarHelper.show(context, "Biometric login failed: ${e.toString()}");
    }
  }

  Future<void> _showBiometricSetupDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.fingerprint, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              const Text('Enable Biometric Login'),
            ],
          ),
          content: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Text(
                'Would you like to enable ${authProvider.biometricTypeName} login for faster access?',
                style: const TextStyle(fontSize: 16),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Skip'),
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToMainApp();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Enable'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _setupBiometricLogin();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _setupBiometricLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.enableBiometricLogin(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      SnackbarHelper.show(
        context,
        "${authProvider.biometricTypeName} login enabled successfully!",
      );

      _navigateToMainApp();
    } catch (e) {
      SnackbarHelper.show(
        context,
        "Failed to enable biometric login: ${e.toString()}",
      );
      _navigateToMainApp();
    }
  }

  void _navigateToMainApp() {
    Navigator.pushReplacement(
      context,
      PageTransition(
        child: AppRoutes.getPage(AppRoutes.mainNavigation),
        type: PageTransitionType.scale,
        alignment: Alignment.center,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.grey),
              ),
              color: Colors.transparent,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints(),
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            isLogin
                                ? "Welcome back!\nGlad to see you,\nAgain!"
                                : "Hello!\nRegister to get started",
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 30),

                          if (isLogin) ...[
                            CustomTextField(
                              controller: emailController,
                              hintText: "Email",
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: passwordController,
                              hintText: "Password",
                              isPassword: true,
                              obscureText: obscurePassword,
                              onVisibilityToggle: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                          ] else ...[
                            CustomTextField(
                              controller: usernameController,
                              hintText: "Username",
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: emailController,
                              hintText: "Email",
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: passwordController,
                              hintText: "Password",
                              isPassword: true,
                              obscureText: obscurePassword,
                              onVisibilityToggle: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: confirmPasswordController,
                              hintText: "Confirm Password",
                              isPassword: true,
                              obscureText: obscureConfirmPassword,
                              onVisibilityToggle: () {
                                setState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (isLogin) ...[
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Forgot password logic
                                },
                                child: const Text(
                                  "Forgot password?",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 8),

                          CustomButton(
                            text: isLogin ? "Login" : "Register",
                            onPressed: () async {
                              if (isLogin) {
                                final email = emailController.text.trim();
                                final password = passwordController.text.trim();

                                if (email.isEmpty || password.isEmpty) {
                                  SnackbarHelper.show(
                                    context,
                                    "Please enter email and password",
                                  );
                                  return;
                                }

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) =>
                                      const Center(child: AppLoader()),
                                );

                                try {
                                  await authProvider.login(email, password);
                                  if (!context.mounted) return;

                                  final loginCount = await _loginCountService
                                      .incrementLoginCount();
                                  Navigator.of(context).pop();

                                  final message = authProvider.user != null
                                      ? "Welcome ${authProvider.user!.name}! (Login #$loginCount)"
                                      : "Login successful! (Login #$loginCount)";

                                  SnackbarHelper.show(context, message);

                                  // Show biometric setup dialog if available and not already enabled
                                  if (authProvider.isBiometricAvailable &&
                                      !authProvider.isBiometricEnabled) {
                                    await _showBiometricSetupDialog();
                                  } else {
                                    _navigateToMainApp();
                                  }
                                } catch (e) {
                                  Navigator.of(context).pop();
                                  SnackbarHelper.show(
                                    context,
                                    "Login failed: ${e.toString()}",
                                  );
                                }
                              } else {
                                SnackbarHelper.show(
                                  context,
                                  "Registration not implemented yet.",
                                );
                              }
                            },
                            backgroundColor: AppColors.primary,
                            textColor: Colors.white,
                          ),

                          // Show biometric login button only for login mode and when available & enabled
                          if (isLogin &&
                              authProvider.isBiometricAvailable &&
                              authProvider.isBiometricEnabled) ...[
                            BiometricLoginButton(
                              onPressed: _handleBiometricLogin,
                              isLoading: authProvider.isLoading,
                              availableBiometrics: availableBiometrics,
                              biometricTypeName: authProvider.biometricTypeName,
                            ),
                          ],

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLogin
                                    ? "Don't have an account?"
                                    : "Already have an account?",
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    isLogin = !isLogin;
                                    usernameController.clear();
                                    emailController.clear();
                                    passwordController.clear();
                                    confirmPasswordController.clear();
                                    obscurePassword = true;
                                    obscureConfirmPassword = true;
                                  });
                                },
                                child: Text(
                                  isLogin ? "Register now" : "Login",
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Optional: Floating biometric button (alternative placement)
              // Uncomment if you prefer this over the integrated button
              /*
              if (isLogin &&
                  authProvider.isBiometricAvailable &&
                  authProvider.isBiometricEnabled)
                FloatingBiometricButton(
                  onPressed: _handleBiometricLogin,
                  isLoading: authProvider.isLoading,
                  availableBiometrics: availableBiometrics,
                ),
              */
            ],
          );
        },
      ),
    );
  }
}
