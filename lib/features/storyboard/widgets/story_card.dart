// import 'package:flutter/material.dart';
// import 'package:goreto/core/constants/appColors.dart';
//
// class StoryCard extends StatelessWidget {
//   final String title;
//   final String description;
//   final VoidCallback onPressed;
//   final bool isLast;
//   final double width;
//
//   const StoryCard({
//     super.key,
//     required this.title,
//     required this.description,
//     required this.onPressed,
//     required this.isLast,
//     required this.width,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 25),
//       width: double.infinity,
//       padding: const EdgeInsets.all(22.0),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(25.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Image.asset("assets/logos/goreto.png", width: 100, height: 100),
//           Text(
//             textAlign: TextAlign.start,
//             title,
//             style: const TextStyle(
//               fontSize: 30,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF192639),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             description,
//             textAlign: TextAlign.start,
//             style: TextStyle(
//               fontSize: 19,
//               fontWeight: FontWeight.w400,
//               color: Colors.grey[800],
//             ),
//           ),
//           const SizedBox(height: 30),
//           Center(
//             child: ElevatedButton(
//               onPressed: onPressed,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.secondary,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 40,
//                   vertical: 16,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               child: Text(
//                 isLast ? 'Get Started' : 'Next',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:goreto/core/constants/appColors.dart';

class StoryCard extends StatefulWidget {
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
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _buttonController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _buttonController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _buttonController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 25),
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(28.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo with subtle animation
          Hero(
            tag: 'goreto_logo',
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              child: Image.asset(
                "assets/logos/goreto.png",
                width: 90,
                height: 90,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Animated title
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF192639),
              height: 1.2,
            ),
            child: Text(widget.title, textAlign: TextAlign.start),
          ),

          const SizedBox(height: 12),

          // Animated description
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: Colors.grey[700],
              height: 1.4,
            ),
            child: Text(widget.description, textAlign: TextAlign.start),
          ),

          const SizedBox(height: 28),

          // Animated button
          Center(
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: widget.onPressed,
              child: AnimatedBuilder(
                animation: _buttonScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _buttonScaleAnimation.value,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: _isPressed
                            ? AppColors.secondary.withOpacity(0.8)
                            : AppColors.secondary,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: _isPressed
                            ? [
                                BoxShadow(
                                  color: AppColors.secondary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: AppColors.secondary.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: AppColors.secondary.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 16,
                          color: _isPressed
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        child: Text(widget.isLast ? 'Get Started' : 'Next'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
