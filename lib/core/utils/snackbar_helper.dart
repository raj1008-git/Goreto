import 'package:flutter/material.dart';
import '../constants/appColors.dart';

class SnackbarHelper {
  static void show(
    BuildContext context,
    String message, {
    Color backgroundColor = AppColors.primary,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        duration: duration,
      ),
    );
  }
}
