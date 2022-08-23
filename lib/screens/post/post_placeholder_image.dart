import 'dart:ui';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
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
    final pageCookies = ref.watch(pageCookieProvider);
    return ExtendedImage.network(
      post.previewFile,
      headers: {
        'Referer': post.postUrl,
        'Cookie': CookieManager.getCookies(pageCookies),
      },
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
