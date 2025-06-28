import 'package:flutter/material.dart';
import 'package:goreto/features/auth/screens/auth_screen.dart';
import 'package:goreto/features/auth/screens/login_or_register.dart';
import 'package:page_transition/page_transition.dart';

import '../features/splash/screens/splash_screen.dart';
import '../features/storyboard/screens/story_board.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String story = '/storyBoard';
  static const String dashboard = '/dashboard';
  static const String loginorregister = '/loginorregister';
  static const String auth = '/auth';
  // Add more named routes here as needed

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildPage(const SplashScreen());
      case dashboard:
        return _buildPage(const DashboardScreen());
      case story:
        return _buildPage(const StoryBoardScreen());

      case loginorregister:
        return _buildPage(const LoginOrRegisterScreen());
      // Add more cases here
      case auth:
        return _buildPage(const AuthScreen());
      default:
        return _errorRoute();
    }
  }

  static Widget getPage(String routeName, {Object? arguments}) {
    switch (routeName) {
      case dashboard:
        return const DashboardScreen();
      case splash:
        return const SplashScreen();
      case story:
        return const StoryBoardScreen();
      case loginorregister:
        return const LoginOrRegisterScreen();
      case auth:
        final isLogin = (arguments is bool) ? arguments : true;
        return AuthScreen(isInitiallyLogin: isLogin);
      default:
        return const Scaffold(body: Center(child: Text("404")));
    }
  }

  static PageTransition _buildPage(Widget child) {
    return PageTransition(
      child: child,
      type: PageTransitionType.fade,
      duration: const Duration(milliseconds: 500),
    );
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) =>
          Scaffold(body: Center(child: Text('404 - Page not found'))),
    );
  }
}
