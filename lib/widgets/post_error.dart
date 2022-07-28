import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/post.dart';
import '../../provider/settings/blur_explicit_post.dart';
import '../../utils/string_ext.dart';
import 'post_placeholder_image.dart';

class PostErrorDisplay extends HookConsumerWidget {
  const PostErrorDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blurExplicitPost = ref.watch(blurExplicitPostProvider);
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PostPlaceholderImage(
                url: post.previewFile, shouldBlur: blurExplicitPost),
            Card(
              margin: const EdgeInsets.fromLTRB(16, 32, 16, 32),
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: Text(
                  '${post.contentFile.mimeType} is unsupported at the moment',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
