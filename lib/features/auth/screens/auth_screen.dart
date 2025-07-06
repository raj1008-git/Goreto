import 'package:flutter/material.dart';
import 'package:goreto/core/utils/snackbar_helper.dart';
import 'package:goreto/data/providers/auth_provider.dart';
import 'package:goreto/routes/app_routes.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/appColors.dart';
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

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    isLogin = widget.isInitiallyLogin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Colors.black,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.pop(context),
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
                      color: AppColors.primary,
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
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        try {
                          await authProvider.login(email, password);
                          if (!context.mounted) return;

                          // Close loader
                          Navigator.of(context).pop();

                          // Show beautiful snackbar
                          final message = authProvider.user != null
                              ? "Welcome ${authProvider.user!.name}!"
                              : "Login successful";

                          SnackbarHelper.show(context, message);

                          // Navigate with fade transition
                          Navigator.pushReplacement(
                            context,
                            PageTransition(
                              child: AppRoutes.getPage(
                                AppRoutes.mainNavigation,
                              ),

                              type: PageTransitionType.fade,
                              duration: const Duration(milliseconds: 700),
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

                  SizedBox(height: 50),

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
