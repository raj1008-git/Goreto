import 'package:flutter/material.dart';
import 'package:goreto/data/models/places/place_model.dart';
import 'package:goreto/features/auth/screens/auth_screen.dart';
import 'package:goreto/features/auth/screens/login_or_register.dart';
import 'package:goreto/features/maps/screens/maps_screen.dart';
import 'package:goreto/features/placeDetail/screens/place_detail_screen.dart';
import 'package:goreto/features/splash/screens/splash_screen.dart';
import 'package:goreto/features/storyboard/screens/story_board.dart';
import 'package:goreto/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:goreto/presentation/screens/main_navigation_screen_controller.dart';
import 'package:page_transition/page_transition.dart';

import '../features/group/group_screen.dart';
import '../features/search/widgets/search_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String story = '/storyBoard';
  static const String dashboard = '/dashboard';
  static const String loginorregister = '/loginorregister';
  static const String auth = '/auth';
  static const String mainNavigation = '/mainNavigation';
  static const String mapScreen = '/mapScreen';
  static const String placeDetail = '/placeDetail';
  static const String search = '/search';
  static const String groupScreen = '/groupCreate';

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
      case auth:
        final isLogin = (settings.arguments as bool?) ?? true;
        return _buildPage(AuthScreen(isInitiallyLogin: isLogin));
      case mainNavigation:
        return _buildPage(const MainNavigationScreen());
      case mapScreen:
        return _buildPage(const PopularPlacesMapScreen());
      case placeDetail:
        final place = settings.arguments as PlaceModel;
        return _buildPage(PlaceDetailScreen(place: place));
      case search:
        return _buildPage(const SearchScreen());
      case groupScreen:
        return _buildPage(GroupScreen());

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
      case mainNavigation:
        return const MainNavigationScreen();
      case mapScreen:
        return const PopularPlacesMapScreen();
      case placeDetail:
        return PlaceDetailScreen(place: arguments as PlaceModel);
      case groupScreen:
        return GroupScreen();

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
          const Scaffold(body: Center(child: Text('404 - Page not found'))),
    );
  }
}
