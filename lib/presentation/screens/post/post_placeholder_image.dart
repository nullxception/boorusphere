import 'dart:ui';

import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/screens/post/hooks/post_headers.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostPlaceholderImage extends HookConsumerWidget {
  const PostPlaceholderImage({
    super.key,
    required this.post,
    required this.shouldBlur,
  });

  final Post post;
  final bool shouldBlur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headers = usePostHeaders(ref, post);
    final retries = useState(0);

    return ExtendedImage.network(
      post.previewFile,
      headers: headers.data,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      enableLoadState: false,
      loadStateChanged: (state) {
        if (state.extendedImageLoadState == LoadState.failed &&
            retries.value < 5) {
          Future.delayed(const Duration(milliseconds: 150), (() {
            state.reLoadImage();
            retries.value += 1;
          }));
        }
      },
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
