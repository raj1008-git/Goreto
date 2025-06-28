import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

PageRoute buildSlideTransition(Widget child) {
  return PageTransition(
    type: PageTransitionType.fade,
    duration: const Duration(milliseconds: 550),
    child: child,
  );
}
