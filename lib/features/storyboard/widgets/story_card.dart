import 'package:flutter/material.dart';
import 'package:goreto/core/constants/appColors.dart';

class StoryCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onPressed;
  final bool isLast;
  final double width;

  const StoryCard({
    super.key,
    required this.title,
    required this.description,
    required this.onPressed,
    required this.isLast,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            textAlign: TextAlign.start,
            title,
            style: const TextStyle(
              fontSize: 30,
              letterSpacing: -0.17,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 20,
              letterSpacing: -0.17,
              fontWeight: FontWeight.w400,
              color: Color(0xBF000000),
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFF176),
                    Color(0xFFFCAC43),
                  ], // light to dark yellow
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Center(
                  child: Text(
                    isLast ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
