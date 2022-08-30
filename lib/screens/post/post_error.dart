import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../entity/post.dart';
import '../../source/settings/blur_explicit_post.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../utils/extensions/string.dart';
import 'post_placeholder_image.dart';
import 'quickbar.dart';

class PostErrorDisplay extends HookConsumerWidget {
  const PostErrorDisplay({
    super.key,
    required this.post,
    this.heroKey,
  });

  final Post post;
  final Object? heroKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldBlur = ref.watch(blurExplicitPostProvider);
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        Hero(
          tag: heroKey ?? post.id,
          child: PostPlaceholderImage(
            post: post,
            shouldBlur: shouldBlur && post.rating == PostRating.explicit,
          ),
        ),
        Positioned(
          bottom: context.mediaQuery.viewInsets.bottom +
              kBottomNavigationBarHeight +
              32,
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
