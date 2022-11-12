import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/provider/setting/post/blur_explicit.dart';
import 'package:boorusphere/presentation/screens/post/post_placeholder_image.dart';
import 'package:boorusphere/presentation/screens/post/quickbar.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
            title: Text('${post.content.url.fileExtension} is not supported'),
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
