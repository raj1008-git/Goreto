// import 'package:flutter/material.dart';
//
// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//   final Color backgroundColor;
//   final Color textColor;
//
//   const CustomButton({
//     super.key,
//     required this.text,
//     required this.onPressed,
//     required this.backgroundColor,
//     required this.textColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: backgroundColor,
//           foregroundColor: textColor,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         onPressed: onPressed,
//         child: Text(text, style: const TextStyle(fontSize: 18)),
//       ),
//     );
//   }
// }
// lib/presentation/auth/widgets/custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final Widget? icon;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
    this.borderColor,
    this.icon,
    this.height = 56,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 12),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
