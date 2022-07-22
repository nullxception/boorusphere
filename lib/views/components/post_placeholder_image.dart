import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class PostPlaceholderImage extends StatelessWidget {
  const PostPlaceholderImage({
    Key? key,
    required this.url,
    required this.shouldBlur,
  }) : super(key: key);

  final String url;
  final bool shouldBlur;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      url,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      enableLoadState: false,
      loadStateChanged: (state) {
        final isCompleted = state.extendedImageLoadState == LoadState.completed;
        if (isCompleted && shouldBlur) {
          return ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: state.completedWidget,
          );
        }

        return state.completedWidget;
      },
    );
  }
}
