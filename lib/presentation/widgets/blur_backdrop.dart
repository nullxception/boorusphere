import 'dart:ui';

import 'package:flutter/material.dart';

class BlurBackdrop extends StatelessWidget {
  const BlurBackdrop({
    super.key,
    required this.child,
    this.sigmaX = 0,
    this.sigmaY = 0,
    this.tileMode,
    this.blur = false,
  });

  final Widget child;
  final double sigmaX;
  final double sigmaY;
  final bool blur;
  final TileMode? tileMode;

  @override
  Widget build(BuildContext context) {
    return !blur
        ? child
        : ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
              child: child,
            ),
          );
  }
}
