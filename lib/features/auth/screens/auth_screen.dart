import 'package:flutter/material.dart';

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
              CustomTextField(controller: emailController, hintText: "Email"),
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
              CustomTextField(controller: emailController, hintText: "Email"),
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
              onPressed: () {
                // TODO: Add login or register action here
              },
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
            ),

            const Spacer(),

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
    );
  }
}
