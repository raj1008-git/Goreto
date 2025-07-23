import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goreto/core/utils/app_loader.dart';
import 'package:goreto/core/utils/snackbar_helper.dart';
import 'package:goreto/data/providers/auth_provider.dart';
import 'package:goreto/routes/app_routes.dart';
import 'package:local_auth/local_auth.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/appColors.dart';
import '../../../core/services/login_count_service.dart';
import '../../../core/services/secure_storage_service.dart';
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
  bool rememberMe = true; // Default to true
  bool canCheckBiometrics = false;
  bool hasSavedCredentials = false;

  final LocalAuthentication localAuth = LocalAuthentication();
  final LoginCountService _loginCountService = LoginCountService();
  final SecureStorageService _secureStorage = SecureStorageService();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    isLogin = widget.isInitiallyLogin;
    _initializeBiometrics();
    _checkSavedCredentials();
  }

  Future<void> _initializeBiometrics() async {
    try {
      final bool isAvailable = await localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await localAuth.isDeviceSupported();

      setState(() {
        canCheckBiometrics = isAvailable && isDeviceSupported;
      });
    } catch (e) {
      print('Error initializing biometrics: $e');
    }
  }

  Future<void> _checkSavedCredentials() async {
    try {
      final String? savedEmail = await _secureStorage.read('user_email');
      final String? savedPassword = await _secureStorage.read('user_password');

      setState(() {
        hasSavedCredentials = savedEmail != null && savedPassword != null;
      });

      if (hasSavedCredentials && isLogin) {
        emailController.text = savedEmail!;
        passwordController.text = savedPassword!;
      }
    } catch (e) {
      print('Error checking saved credentials: $e');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (!canCheckBiometrics || !hasSavedCredentials) {
      SnackbarHelper.show(
        context,
        "Biometric authentication not available or no saved credentials",
      );
      return;
    }

    try {
      final List<BiometricType> availableBiometrics = await localAuth
          .getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        SnackbarHelper.show(context, "No biometric authentication available");
        return;
      }

      String authReason = "Use your ";
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        authReason += "fingerprint";
      }
      if (availableBiometrics.contains(BiometricType.face)) {
        if (authReason.contains("fingerprint")) {
          authReason += " or face";
        } else {
          authReason += "face";
        }
      }
      authReason += " to authenticate";

      final bool didAuthenticate = await localAuth.authenticate(
        localizedReason: authReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        await _performLogin(useBiometric: true);
      }
    } on PlatformException catch (e) {
      SnackbarHelper.show(
        context,
        "Biometric authentication error: ${e.message}",
      );
    } catch (e) {
      SnackbarHelper.show(context, "Authentication failed: $e");
    }
  }

  Future<void> _performLogin({bool useBiometric = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    String email, password;

    if (useBiometric && hasSavedCredentials) {
      email = await _secureStorage.read('user_email') ?? '';
      password = await _secureStorage.read('user_password') ?? '';
    } else {
      email = emailController.text.trim();
      password = passwordController.text.trim();
    }

    if (email.isEmpty || password.isEmpty) {
      SnackbarHelper.show(context, "Please enter email and password");
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

      // Store credentials securely if remember me is checked and login is successful
      if (rememberMe && !useBiometric) {
        await _secureStorage.write('user_email', email);
        await _secureStorage.write('user_password', password);
        setState(() {
          hasSavedCredentials = true;
        });
      }

      // Increment login count after successful login
      final loginCount = await _loginCountService.incrementLoginCount();
      print('Login count: $loginCount');

      // Close loader
      Navigator.of(context).pop();

      // Show beautiful snackbar
      final authMethod = useBiometric ? "biometric" : "password";
      final message = authProvider.user != null
          ? "Welcome ${authProvider.user!.name}! Authenticated via $authMethod (Login #$loginCount)"
          : "Login successful via $authMethod! (Login #$loginCount)";

      SnackbarHelper.show(context, message);

      // Navigate with fade transition
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
      Navigator.of(context).pop(); // Close loader
      SnackbarHelper.show(context, "Login failed: ${e.toString()}");
    }
  }

  Widget _buildBiometricButtons() {
    if (!canCheckBiometrics || !hasSavedCredentials || !isLogin) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<BiometricType>>(
      future: localAuth.getAvailableBiometrics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final availableBiometrics = snapshot.data!;

        return Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Or authenticate with",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (availableBiometrics.contains(BiometricType.fingerprint))
                  _buildBiometricButton(
                    icon: Icons.fingerprint,
                    label: "Fingerprint",
                    onTap: _authenticateWithBiometrics,
                  ),
                if (availableBiometrics.contains(BiometricType.fingerprint) &&
                    availableBiometrics.contains(BiometricType.face))
                  const SizedBox(width: 24),
                if (availableBiometrics.contains(BiometricType.face))
                  _buildBiometricButton(
                    icon: Icons.face,
                    label: "Face ID",
                    onTap: _authenticateWithBiometrics,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildBiometricButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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

                    // Remember Me Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        const Text(
                          "Remember me",
                          style: TextStyle(color: Colors.black87),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            // TODO: Forgot password logic
                          },
                          child: const Text(
                            "Forgot password?",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
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

                  const SizedBox(height: 8),

                  CustomButton(
                    text: isLogin ? "Login" : "Register",
                    onPressed: () async {
                      if (isLogin) {
                        await _performLogin();
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

                  // Biometric authentication buttons
                  _buildBiometricButtons(),

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

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
