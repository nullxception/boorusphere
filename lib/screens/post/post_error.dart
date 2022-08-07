import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../entity/post.dart';
import '../../settings/blur_explicit_post.dart';
import '../../utils/extensions/string.dart';
import 'post_placeholder_image.dart';
import 'quickbar.dart';

class PostErrorDisplay extends HookConsumerWidget {
  const PostErrorDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldBlur = ref.watch(blurExplicitPostProvider);
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        Hero(
          tag: post.id,
          child: PostPlaceholderImage(
            post: post,
            shouldBlur: shouldBlur && post.rating == PostRating.explicit,
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).viewPadding.bottom + 32,
          child: QuickBar.action(
            title: Text('${post.contentFile.fileExtension} is not supported'),
            actionTitle: const Text('Open externally'),
            onPressed: () {
              launchUrlString(post.originalFile,
                  mode: LaunchMode.externalApplication);
            },
          ),
        ),
      ],
    );
  }
}
