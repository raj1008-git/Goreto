import 'package:flutter/material.dart';
import 'package:goreto/core/utils/app_loader.dart';
import 'package:goreto/core/utils/snackbar_helper.dart';
import 'package:goreto/data/providers/auth_provider.dart';
import 'package:goreto/routes/app_routes.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/appColors.dart';
import '../../../core/services/login_count_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

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
  }

  Future<void> _handleBiometricLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: AppLoader()),
      );

      await authProvider.loginWithBiometric();

      if (!context.mounted) return;

      // Increment login count after successful login
      final loginCount = await _loginCountService.incrementLoginCount();

      // Close loader
      Navigator.of(context).pop();

      // Show success message
      final message = authProvider.user != null
          ? "Welcome back ${authProvider.user!.name}"
          : "Biometric login successful! (Login #$loginCount)";

      SnackbarHelper.show(context, message);

      // Navigate to main navigation
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
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loader
      SnackbarHelper.show(context, "Biometric login failed: ${e.toString()}");
    }
  }

  Future<void> _showBiometricSetupDialog() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enable ${authProvider.biometricTypeName}'),
          content: Text(
            'Would you like to enable ${authProvider.biometricTypeName.toLowerCase()} login for faster access next time?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Skip'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Enable'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await authProvider.enableBiometricLogin(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
                  if (!context.mounted) return;
                  SnackbarHelper.show(
                    context,
                    '${authProvider.biometricTypeName} login enabled successfully!',
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  SnackbarHelper.show(
                    context,
                    'Failed to enable biometric login: ${e.toString()}',
                  );
                }
              },
            ),
          ],
        );
      },
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismiss keyboard on tap
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
                          obscureConfirmPassword = !obscureConfirmPassword;
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

                  // Regular Login/Register Button
                  CustomButton(
                    text: isLogin ? "Login" : "Register",
                    onPressed: () async {
                      if (isLogin) {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();

                        if (email.isEmpty || password.isEmpty) {
                          SnackbarHelper.show(
                            context,
                            "Please enter email and password",
                          );
                          return;
                        }

                        // Show loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: AppLoader()),
                        );

                        try {
                          await authProvider.login(email, password);
                          if (!context.mounted) return;

                          // Increment login count after successful login
                          final loginCount = await _loginCountService
                              .incrementLoginCount();

                          // Close loader
                          Navigator.of(context).pop();

                          // Show biometric setup dialog if available and not enabled
                          if (authProvider.isBiometricAvailable &&
                              !authProvider.isBiometricEnabled) {
                            await _showBiometricSetupDialog();
                          }

                          // Show beautiful snackbar
                          final message = authProvider.user != null
                              ? "Welcome ${authProvider.user!.name}"
                              : "Login successful! (Login #$loginCount)";

                          SnackbarHelper.show(context, message);

                          // Navigate with fade transition
                          Navigator.pushReplacement(
                            context,
                            PageTransition(
                              child: AppRoutes.getPage(
                                AppRoutes.mainNavigation,
                              ),
                              type: PageTransitionType.scale,
                              alignment: Alignment.center,
                              duration: const Duration(milliseconds: 800),
                            ),
                          );
                        } catch (e) {
                          Navigator.of(context).pop(); // Close loader
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

                  // Biometric Login Button (only show if login mode and biometric is available)
                  if (isLogin) ...[
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.isBiometricAvailable &&
                            authProvider.isBiometricEnabled) {
                          return Column(
                            children: [
                              const SizedBox(height: 16),
                              // OR divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      "OR",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Biometric login button
                              CustomButton(
                                text:
                                    "Login with ${authProvider.biometricTypeName}",
                                onPressed: _handleBiometricLogin,
                                backgroundColor: Colors.white,
                                textColor: AppColors.primary,
                                borderColor: AppColors.primary,
                                icon: Icon(
                                  Icons.fingerprint,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],

                  const SizedBox(height: 50),

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
                            // Clear controllers optionally when switching modes
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
    );
  }
}
