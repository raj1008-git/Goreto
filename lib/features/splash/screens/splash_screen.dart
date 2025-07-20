import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:goreto/core/utils/app_loader.dart';
import 'package:page_transition/page_transition.dart';

import '../../../core/utils/media_query_helper.dart';
import '../../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navigationTimer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAsyncInitialization();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  void _startAsyncInitialization() {
    // Start heavy operations in background using compute or isolate
    _performBackgroundInitialization().then((_) {
      if (mounted && !_isNavigating) {
        _scheduleNavigation();
      }
    });
  }

  Future<void> _performBackgroundInitialization() async {
    // Simulate heavy initialization tasks that might be blocking
    final futures = <Future>[
      // Preload critical assets
      _preloadAssets(),
      // Initialize app dependencies
      _initializeAppDependencies(),
      // Minimum splash time
      Future.delayed(const Duration(milliseconds: 2500)),
    ];

    await Future.wait(futures);
  }

  Future<void> _preloadAssets() async {
    return compute(_preloadCriticalAssets, null);
  }

  static Future<void> _preloadCriticalAssets(dynamic _) async {
    // This runs in a separate isolate to avoid blocking UI
    await Future.delayed(const Duration(milliseconds: 500));
    // Add your asset preloading logic here
  }

  Future<void> _initializeAppDependencies() async {
    // Initialize providers, databases, etc. asynchronously
    return Future.delayed(const Duration(milliseconds: 300));
  }

  void _scheduleNavigation() {
    if (!mounted || _isNavigating) return;

    _isNavigating = true;
    _navigationTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.leftToRight,
        duration: const Duration(milliseconds: 800), // Reduced duration
        child: AppRoutes.getPage(AppRoutes.story),
        settings: const RouteSettings(name: AppRoutes.story),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated App Logo
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Hero(
                        tag: 'app_logo',
                        child: Container(
                          width: screen.widthP(60),
                          height: screen.widthP(60),
                          child: Image.asset(
                            'assets/logos/goreto.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screen.heightP(5)),

                  // Animated Progress Indicator
                  FadeTransition(opacity: _fadeAnimation, child: AppLoader()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
