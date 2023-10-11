import 'package:flutter/material.dart';

import '../main.dart';

class GradientCircularProgressIndicator extends StatelessWidget {
  final double? value;

  const GradientCircularProgressIndicator({super.key, this.value});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: [primaryColor, amberColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            tileMode: TileMode.clamp,
          ).createShader(bounds);
        },
        child: CircularProgressIndicator(
          value:
              value, // null for indeterminate, value between 0.0 and 1.0 for determinate
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 7.0,
        ),
      ),
    );
  }
}
