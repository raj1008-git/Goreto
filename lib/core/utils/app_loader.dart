import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../constants/appColors.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final Color color;

  const AppLoader({
    super.key,
    this.size = 34.0,
    this.color = AppColors.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitChasingDots(color: color, size: size),
    );
  }
}
