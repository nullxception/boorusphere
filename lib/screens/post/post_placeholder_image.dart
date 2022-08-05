import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../../entity/post.dart';

class PostPlaceholderImage extends StatelessWidget {
  const PostPlaceholderImage({
    super.key,
    required this.post,
    required this.shouldBlur,
  });

  final Post post;
  final bool shouldBlur;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      post.previewFile,
      headers: {'Referer': post.postUrl},
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      enableLoadState: false,
      loadStateChanged: (state) {
        final isCompleted = state.extendedImageLoadState == LoadState.completed;
        if (isCompleted && shouldBlur) {
          return ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: 8,
              sigmaY: 8,
              tileMode: TileMode.decal,
            ),
            child: state.completedWidget,
          );
        }

        return state.completedWidget;
      },
    );
  }
}
