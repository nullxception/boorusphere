import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entity/post.dart';
import '../../source/page.dart';

class PostPlaceholderImage extends ConsumerWidget {
  const PostPlaceholderImage({
    super.key,
    required this.post,
    required this.shouldBlur,
  });

  final Post post;
  final bool shouldBlur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageCookies =
        ref.watch(pageDataProvider.select((value) => value.cookies));
    return ExtendedImage.network(
      post.previewFile,
      headers: {
        'Referer': post.postUrl,
        'Cookie': pageCookies,
      },
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      enableLoadState: false,
      beforePaintImage: (canvas, rect, image, paint) {
        if (shouldBlur) {
          paint.imageFilter = ImageFilter.blur(
            sigmaX: 8,
            sigmaY: 8,
            tileMode: TileMode.decal,
          );
        }
        return false;
      },
    );
  }
}
