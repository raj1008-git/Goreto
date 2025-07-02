import 'package:flutter/material.dart';
import 'package:goreto/screens/auth/otp.dart';
import '../screens/auth/login.dart';
import '../screens/auth/signup.dart';
import '../screens/auth/forgot_password.dart';
import '../screens/chat/chat_list_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String chatList = '/chat-list';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => LoginPage(),
    signup: (context) => SignupPage(),
    forgotPassword: (context) => ForgotPasswordPage(),
    otp: (context) => OTPVerificationPage(),
    chatList: (context) => ChatListPage(),
  };
}
