import 'dart:ui';

import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class PostPlaceholderImage extends StatelessWidget {
  const PostPlaceholderImage({
    super.key,
    required this.post,
    required this.shouldBlur,
    this.headers,
  });

  final Post post;
  final bool shouldBlur;
  final Map<String, String>? headers;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      post.previewFile,
      headers: headers,
      fit: BoxFit.contain,
      enableLoadState: false,
      beforePaintImage: (canvas, rect, image, paint) {
        if (shouldBlur) {
          paint.imageFilter = ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
            tileMode: TileMode.decal,
          );
        }
        return false;
      },
    );
  }
}
