import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../../../core/constants/appColors.dart';
import '../../../routes/app_routes.dart';
import '../animation/login_register_animator.dart';
import '../widgets/custom_button.dart';

class LoginOrRegisterScreen extends StatefulWidget {
  const LoginOrRegisterScreen({super.key});

  @override
  State<LoginOrRegisterScreen> createState() => _LoginOrRegisterScreenState();
}

class _LoginOrRegisterScreenState extends State<LoginOrRegisterScreen>
    with SingleTickerProviderStateMixin {
  late LoginRegisterAnimator _animator;

  @override
  void initState() {
    super.initState();
    _animator = LoginRegisterAnimator(vsync: this);
  }

  @override
  void dispose() {
    _animator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/story4.jpg', fit: BoxFit.cover),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/logos/goreto.png',
                  height: screen.height * 0.15,
                ),

                const SizedBox(height: 0),

                // 🔸 Fade-in container
                FadeTransition(
                  opacity: _animator.fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 40,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 30,
                        left: 30,
                        right: 30,
                        bottom: 20,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                          bottom: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomButton(
                            text: "Login",
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.fade,
                                  duration: const Duration(milliseconds: 1000),
                                  child: AppRoutes.getPage(
                                    AppRoutes.auth,
                                    arguments: true,
                                  ), // false = show register screen
                                  settings: const RouteSettings(
                                    name: AppRoutes.auth,
                                  ),
                                ),
                              );
                            },
                            backgroundColor: AppColors.primary,
                            textColor: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            text: "Register",
                            onPressed: () {},
                            backgroundColor: Colors.grey.shade200,
                            textColor: Colors.black,
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.fade,
                                  duration: const Duration(milliseconds: 1000),
                                  child: AppRoutes.getPage(
                                    AppRoutes.auth,
                                    arguments: false,
                                  ), // false = show register screen
                                  settings: const RouteSettings(
                                    name: AppRoutes.auth,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Continue as guest",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
