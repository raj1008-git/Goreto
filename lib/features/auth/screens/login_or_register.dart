// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:page_transition/page_transition.dart';
//
// import '../../../core/constants/appColors.dart';
// import '../../../routes/app_routes.dart';
// import '../animation/login_register_animator.dart';
// import '../widgets/custom_button.dart';
//
// class LoginOrRegisterScreen extends StatefulWidget {
//   const LoginOrRegisterScreen({super.key});
//
//   @override
//   State<LoginOrRegisterScreen> createState() => _LoginOrRegisterScreenState();
// }
//
// class _LoginOrRegisterScreenState extends State<LoginOrRegisterScreen>
//     with SingleTickerProviderStateMixin {
//   late LoginRegisterAnimator _animator;
//   bool _isNavigating = false;
//   bool _imageLoaded = false;
//   ImageProvider? _cachedBackgroundImage;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeComponents();
//   }
//
//   void _initializeComponents() {
//     _animator = LoginRegisterAnimator(vsync: this);
//     _preloadBackgroundImage();
//   }
//
//   Future<void> _preloadBackgroundImage() async {
//     _cachedBackgroundImage = const AssetImage('assets/images/story4.jpg');
//
//     try {
//       // Wait for image to be fully cached before starting animations
//       await precacheImage(_cachedBackgroundImage!, context);
//
//       if (mounted) {
//         setState(() {
//           _imageLoaded = true;
//         });
//
//         // Only start animation after image is loaded
//         SchedulerBinding.instance.addPostFrameCallback((_) {
//           if (mounted) {
//             _animator.startAnimation();
//           }
//         });
//       }
//     } catch (e) {
//       // Handle image loading error
//       if (mounted) {
//         setState(() {
//           _imageLoaded = true; // Still show the screen even if image fails
//         });
//         _animator.startAnimation();
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _animator.dispose();
//     super.dispose();
//   }
//
//   Future<void> _handleNavigation({
//     required PageTransitionType transitionType,
//     required Widget destination,
//     required Duration duration,
//     String? routeName,
//   }) async {
//     if (_isNavigating) return;
//
//     _isNavigating = true;
//
//     // Small delay to let the exit animation settle
//     await Future.delayed(const Duration(milliseconds: 50));
//
//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         PageTransition(
//           type: transitionType,
//           alignment: Alignment.center,
//           duration: duration,
//           child: destination,
//           settings: RouteSettings(name: routeName),
//         ),
//       );
//     }
//   }
//
//   Future<void> _onLoginPressed() async {
//     // Start exit animation first
//     await _animator.reverseAnimation();
//
//     _handleNavigation(
//       transitionType: PageTransitionType.rightToLeftWithFade,
//       destination: AppRoutes.getPage(AppRoutes.auth, arguments: true),
//       duration: const Duration(milliseconds: 600),
//     );
//   }
//
//   Future<void> _onRegisterPressed() async {
//     // Start exit animation first
//     await _animator.reverseAnimation();
//
//     // Add register functionality here - for now just navigate to register screen
//     _handleNavigation(
//       transitionType: PageTransitionType.leftToRightWithFade,
//       destination: AppRoutes.getPage(
//         AppRoutes.auth,
//         arguments: false,
//       ), // Assuming false for register
//       duration: const Duration(milliseconds: 600),
//     );
//   }
//
//   Future<void> _onContinueAsGuestPressed() async {
//     // Start exit animation first
//     await _animator.reverseAnimation();
//
//     _handleNavigation(
//       transitionType: PageTransitionType.fade,
//       destination: AppRoutes.getPage(AppRoutes.auth, arguments: false),
//       duration: const Duration(milliseconds: 800),
//       routeName: AppRoutes.auth,
//     );
//   }
//
//   Widget _buildBackgroundImage() {
//     return Positioned.fill(
//       child: AnimatedOpacity(
//         opacity: _imageLoaded ? 1.0 : 0.0,
//         duration: const Duration(milliseconds: 300),
//         child: _cachedBackgroundImage != null
//             ? Image(
//                 image: _cachedBackgroundImage!,
//                 fit: BoxFit.cover,
//                 // Remove frameBuilder since we're handling loading state manually
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     color: Colors.grey[200],
//                     child: const Center(
//                       child: Icon(Icons.error, color: Colors.grey),
//                     ),
//                   );
//                 },
//               )
//             : Container(color: Colors.grey[200]),
//       ),
//     );
//   }
//
//   Widget _buildLogo(Size screen) {
//     return Hero(
//       tag: 'app_logo',
//       child: Image.asset(
//         'assets/logos/goreto.png',
//         height: screen.height * 0.15,
//         // Add error handling for logo as well
//         errorBuilder: (context, error, stackTrace) {
//           return Container(
//             height: screen.height * 0.15,
//             child: const Icon(Icons.image_not_supported),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildActionButtons() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         CustomButton(
//           text: "Login",
//           onPressed: _onLoginPressed,
//           backgroundColor: AppColors.primary,
//           textColor: Colors.white,
//         ),
//         const SizedBox(height: 12),
//         CustomButton(
//           text: "Register",
//           onPressed: _onRegisterPressed,
//           backgroundColor: Colors.grey.shade200,
//           textColor: Colors.black,
//         ),
//         const SizedBox(height: 16),
//         TextButton(
//           onPressed: _onContinueAsGuestPressed,
//           child: const Text(
//             "Continue as guest",
//             style: TextStyle(
//               fontSize: 16,
//               color: AppColors.secondary,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildAnimatedContent(Size screen) {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           // Logo with fade animation
//           AnimatedBuilder(
//             animation: _animator.fadeAnimation,
//             builder: (context, child) {
//               return Opacity(
//                 opacity: _animator.fadeAnimation.value,
//                 child: _buildLogo(screen),
//               );
//             },
//           ),
//           const SizedBox(height: 0),
//
//           // Card container with fade animation
//           AnimatedBuilder(
//             animation: _animator.fadeAnimation,
//             builder: (context, child) {
//               return Opacity(
//                 opacity: _animator.fadeAnimation.value,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 25,
//                     vertical: 40,
//                   ),
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.only(
//                       top: 30,
//                       left: 30,
//                       right: 30,
//                       bottom: 20,
//                     ),
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.vertical(
//                         top: Radius.circular(30),
//                         bottom: Radius.circular(30),
//                       ),
//                     ),
//                     child: _buildActionButtons(),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Container(
//       color: Colors.grey[100],
//       child: const Center(
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screen = MediaQuery.of(context).size;
//
//     return Scaffold(
//       extendBody: true,
//       extendBodyBehindAppBar: true,
//       body: Stack(
//         children: [
//           _buildBackgroundImage(),
//
//           // Only show content after image is loaded
//           if (_imageLoaded)
//             _buildAnimatedContent(screen)
//           else
//             _buildLoadingState(),
//         ],
//       ),
//     );
//   }
//
//   // Helper function for unawaited futures
//   void unawaited(Future<void> future) {
//     // Intentionally not awaited
//   }
// }
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:page_transition/page_transition.dart';
//
// import '../../../core/constants/appColors.dart';
// import '../../../routes/app_routes.dart';
// import '../animation/login_register_animator.dart';
// import '../widgets/custom_button.dart';
//
// class LoginOrRegisterScreen extends StatefulWidget {
//   const LoginOrRegisterScreen({super.key});
//
//   @override
//   State<LoginOrRegisterScreen> createState() => _LoginOrRegisterScreenState();
// }
//
// class _LoginOrRegisterScreenState extends State<LoginOrRegisterScreen>
//     with SingleTickerProviderStateMixin {
//   late LoginRegisterAnimator _animator;
//   bool _isNavigating = false;
//   bool _imageLoaded = false;
//   ImageProvider? _cachedBackgroundImage;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeComponents();
//   }
//
//   void _initializeComponents() {
//     _animator = LoginRegisterAnimator(vsync: this);
//     _preloadBackgroundImage();
//   }
//
//   Future<void> _preloadBackgroundImage() async {
//     _cachedBackgroundImage = const AssetImage('assets/images/story4.jpg');
//
//     try {
//       await precacheImage(_cachedBackgroundImage!, context);
//
//       if (mounted) {
//         setState(() {
//           _imageLoaded = true;
//         });
//
//         // Start animation immediately after image loads
//         SchedulerBinding.instance.addPostFrameCallback((_) {
//           if (mounted) {
//             _animator.startAnimation();
//           }
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _imageLoaded = true;
//         });
//         _animator.startQuickAnimation(); // Use quick animation on error
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _animator.dispose();
//     super.dispose();
//   }
//
//   Future<void> _handleNavigation({
//     required PageTransitionType transitionType,
//     required Widget destination,
//     required Duration duration,
//     String? routeName,
//   }) async {
//     if (_isNavigating) return;
//
//     _isNavigating = true;
//
//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         PageTransition(
//           type: transitionType,
//           alignment: Alignment.center,
//           duration: duration,
//           child: destination,
//           settings: RouteSettings(name: routeName),
//         ),
//       );
//     }
//   }
//
//   Future<void> _onLoginPressed() async {
//     // Fast exit for responsive feel
//     await _animator.fastExit();
//
//     _handleNavigation(
//       transitionType: PageTransitionType.rightToLeftWithFade,
//       destination: AppRoutes.getPage(AppRoutes.auth, arguments: true),
//       duration: const Duration(milliseconds: 400), // Faster navigation
//     );
//   }
//
//   Future<void> _onRegisterPressed() async {
//     await _animator.fastExit();
//
//     _handleNavigation(
//       transitionType: PageTransitionType.leftToRightWithFade,
//       destination: AppRoutes.getPage(AppRoutes.auth, arguments: false),
//       duration: const Duration(milliseconds: 400),
//     );
//   }
//
//   Future<void> _onContinueAsGuestPressed() async {
//     await _animator.reverseAnimation();
//
//     _handleNavigation(
//       transitionType: PageTransitionType.fade,
//       destination: AppRoutes.getPage(AppRoutes.auth, arguments: false),
//       duration: const Duration(milliseconds: 500),
//       routeName: AppRoutes.auth,
//     );
//   }
//
//   Widget _buildBackgroundImage() {
//     return Positioned.fill(
//       child: AnimatedOpacity(
//         opacity: _imageLoaded ? 1.0 : 0.0,
//         duration: const Duration(milliseconds: 300),
//         child: _cachedBackgroundImage != null
//             ? Image(
//                 image: _cachedBackgroundImage!,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     color: Colors.grey[200],
//                     child: const Center(
//                       child: Icon(Icons.error, color: Colors.grey),
//                     ),
//                   );
//                 },
//               )
//             : Container(color: Colors.grey[200]),
//       ),
//     );
//   }
//
//   Widget _buildAnimatedLogo(Size screen) {
//     return AnimatedBuilder(
//       animation: Listenable.merge([
//         _animator.logoOpacity,
//         _animator.logoScale,
//         _animator.logoSlide,
//       ]),
//       builder: (context, child) {
//         return SlideTransition(
//           position: _animator.logoSlide,
//           child: ScaleTransition(
//             scale: _animator.logoScale,
//             child: Opacity(
//               opacity: _animator.logoOpacity.value,
//               child: Hero(
//                 tag: 'app_logo',
//                 child: Image.asset(
//                   'assets/logos/goreto.png',
//                   height: screen.height * 0.15,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       height: screen.height * 0.15,
//                       child: const Icon(Icons.image_not_supported),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildAnimatedButtons() {
//     return AnimatedBuilder(
//       animation: Listenable.merge([
//         _animator.buttonOpacity,
//         _animator.buttonScale,
//       ]),
//       builder: (context, child) {
//         return ScaleTransition(
//           scale: _animator.buttonScale,
//           child: Opacity(
//             opacity: _animator.buttonOpacity.value,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Stagger button animations slightly
//                 _buildStaggeredButton(
//                   "Login",
//                   _onLoginPressed,
//                   AppColors.primary,
//                   Colors.white,
//                   0,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildStaggeredButton(
//                   "Register",
//                   _onRegisterPressed,
//                   Colors.grey.shade200,
//                   Colors.black,
//                   50, // 50ms delay
//                 ),
//                 const SizedBox(height: 16),
//                 _buildStaggeredTextButton(),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildStaggeredButton(
//     String text,
//     VoidCallback onPressed,
//     Color backgroundColor,
//     Color textColor,
//     int delayMs,
//   ) {
//     return AnimatedBuilder(
//       animation: _animator.buttonOpacity,
//       builder: (context, child) {
//         // Create slight stagger effect
//         double staggeredOpacity =
//             (_animator.buttonOpacity.value - (delayMs * 0.001)).clamp(0.0, 1.0);
//
//         return Opacity(
//           opacity: staggeredOpacity,
//           child: Transform.translate(
//             offset: Offset(0, (1 - staggeredOpacity) * 10), // Subtle slide up
//             child: CustomButton(
//               text: text,
//               onPressed: onPressed,
//               backgroundColor: backgroundColor,
//               textColor: textColor,
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildStaggeredTextButton() {
//     return AnimatedBuilder(
//       animation: _animator.buttonOpacity,
//       builder: (context, child) {
//         double staggeredOpacity = (_animator.buttonOpacity.value - 0.1).clamp(
//           0.0,
//           1.0,
//         );
//
//         return Opacity(
//           opacity: staggeredOpacity,
//           child: Transform.translate(
//             offset: Offset(0, (1 - staggeredOpacity) * 15),
//             child: TextButton(
//               onPressed: _onContinueAsGuestPressed,
//               child: const Text(
//                 "Continue as guest",
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: AppColors.secondary,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildAnimatedCard() {
//     return AnimatedBuilder(
//       animation: Listenable.merge([
//         _animator.cardOpacity,
//         _animator.cardScale,
//         _animator.cardSlide,
//       ]),
//       builder: (context, child) {
//         return SlideTransition(
//           position: _animator.cardSlide,
//           child: ScaleTransition(
//             scale: _animator.cardScale,
//             child: Opacity(
//               opacity: _animator.cardOpacity.value,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 25,
//                   vertical: 40,
//                 ),
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.only(
//                     top: 30,
//                     left: 30,
//                     right: 30,
//                     bottom: 20,
//                   ),
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.vertical(
//                       top: Radius.circular(30),
//                       bottom: Radius.circular(30),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 20,
//                         offset: Offset(0, -5),
//                       ),
//                     ],
//                   ),
//                   child: _buildAnimatedButtons(),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildAnimatedContent(Size screen) {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           _buildAnimatedLogo(screen),
//           const SizedBox(height: 0),
//           _buildAnimatedCard(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Container(
//       color: Colors.grey[100],
//       child: const Center(
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screen = MediaQuery.of(context).size;
//
//     return Scaffold(
//       extendBody: true,
//       extendBodyBehindAppBar: true,
//       body: Stack(
//         children: [
//           _buildBackgroundImage(),
//
//           if (_imageLoaded)
//             _buildAnimatedContent(screen)
//           else
//             _buildLoadingState(),
//         ],
//       ),
//     );
//   }
// }
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  bool _isNavigating = false;
  bool _imageLoaded = false;
  ImageProvider? _cachedBackgroundImage;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
  }

  void _initializeComponents() {
    _animator = LoginRegisterAnimator(vsync: this);
    _preloadBackgroundImage();
  }

  Future<void> _preloadBackgroundImage() async {
    _cachedBackgroundImage = const AssetImage('assets/images/story4.jpg');

    try {
      await precacheImage(_cachedBackgroundImage!, context);

      if (mounted) {
        setState(() {
          _imageLoaded = true;
        });

        // Start animation immediately - background will fade in as part of main animation
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _animator.startAnimation();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _imageLoaded = true;
        });
        _animator.startQuickAnimation();
      }
    }
  }

  @override
  void dispose() {
    _animator.dispose();
    super.dispose();
  }

  Future<void> _handleNavigation({
    required PageTransitionType transitionType,
    required Widget destination,
    required Duration duration,
    String? routeName,
  }) async {
    if (_isNavigating) return;

    _isNavigating = true;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: transitionType,
          alignment: Alignment.center,
          duration: duration,
          child: destination,
          settings: RouteSettings(name: routeName),
        ),
      );
    }
  }

  Future<void> _onLoginPressed() async {
    // Fast exit for responsive feel
    await _animator.fastExit();

    _handleNavigation(
      transitionType: PageTransitionType.rightToLeftWithFade,
      destination: AppRoutes.getPage(AppRoutes.auth, arguments: true),
      duration: const Duration(milliseconds: 400), // Faster navigation
    );
  }

  Future<void> _onRegisterPressed() async {
    await _animator.fastExit();

    _handleNavigation(
      transitionType: PageTransitionType.leftToRightWithFade,
      destination: AppRoutes.getPage(AppRoutes.auth, arguments: false),
      duration: const Duration(milliseconds: 400),
    );
  }

  Future<void> _onContinueAsGuestPressed() async {
    await _animator.reverseAnimation();

    _handleNavigation(
      transitionType: PageTransitionType.fade,
      destination: AppRoutes.getPage(AppRoutes.auth, arguments: false),
      duration: const Duration(milliseconds: 500),
      routeName: AppRoutes.auth,
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _animator.backgroundOpacity,
        builder: (context, child) {
          return Opacity(
            opacity: _imageLoaded ? _animator.backgroundOpacity.value : 0.0,
            child: _cachedBackgroundImage != null
                ? Image(
                    image: _cachedBackgroundImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.error, color: Colors.grey),
                        ),
                      );
                    },
                  )
                : Container(color: Colors.grey[200]),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedLogo(Size screen) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _animator.logoOpacity,
        _animator.logoScale,
        _animator.logoSlide,
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _animator.logoSlide,
          child: ScaleTransition(
            scale: _animator.logoScale,
            child: Opacity(
              opacity: _animator.logoOpacity.value,
              child: Hero(
                tag: 'app_logo',
                child: Image.asset(
                  'assets/logos/goreto.png',
                  height: screen.height * 0.15,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: screen.height * 0.15,
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButtons() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _animator.buttonOpacity,
        _animator.buttonScale,
      ]),
      builder: (context, child) {
        return ScaleTransition(
          scale: _animator.buttonScale,
          child: Opacity(
            opacity: _animator.buttonOpacity.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Stagger button animations slightly
                _buildStaggeredButton(
                  "Login",
                  _onLoginPressed,
                  AppColors.primary,
                  Colors.white,
                  0,
                ),
                const SizedBox(height: 12),
                _buildStaggeredButton(
                  "Register",
                  _onRegisterPressed,
                  Colors.grey.shade200,
                  Colors.black,
                  50, // 50ms delay
                ),
                const SizedBox(height: 16),
                _buildStaggeredTextButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaggeredButton(
    String text,
    VoidCallback onPressed,
    Color backgroundColor,
    Color textColor,
    int delayMs,
  ) {
    return AnimatedBuilder(
      animation: _animator.buttonOpacity,
      builder: (context, child) {
        // Create slight stagger effect
        double staggeredOpacity =
            (_animator.buttonOpacity.value - (delayMs * 0.001)).clamp(0.0, 1.0);

        return Opacity(
          opacity: staggeredOpacity,
          child: Transform.translate(
            offset: Offset(0, (1 - staggeredOpacity) * 10), // Subtle slide up
            child: CustomButton(
              text: text,
              onPressed: onPressed,
              backgroundColor: backgroundColor,
              textColor: textColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaggeredTextButton() {
    return AnimatedBuilder(
      animation: _animator.buttonOpacity,
      builder: (context, child) {
        double staggeredOpacity = (_animator.buttonOpacity.value - 0.1).clamp(
          0.0,
          1.0,
        );

        return Opacity(
          opacity: staggeredOpacity,
          child: Transform.translate(
            offset: Offset(0, (1 - staggeredOpacity) * 15),
            child: TextButton(
              onPressed: _onContinueAsGuestPressed,
              child: const Text(
                "Continue as guest",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCard() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _animator.cardOpacity,
        _animator.cardScale,
        _animator.cardSlide,
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _animator.cardSlide,
          child: ScaleTransition(
            scale: _animator.cardScale,
            child: Opacity(
              opacity: _animator.cardOpacity.value,
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: _buildAnimatedButtons(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedContent(Size screen) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildAnimatedLogo(screen),
          const SizedBox(height: 0),
          _buildAnimatedCard(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildBackgroundImage(),

          if (_imageLoaded)
            _buildAnimatedContent(screen)
          else
            _buildLoadingState(),
        ],
      ),
    );
  }
}
