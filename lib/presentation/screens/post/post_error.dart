import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/settings/content/content_settings.dart';
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
    final shouldBlur = ref.watch(ContentSettingsProvider.blurExplicit);
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
            title: Text(
              t.unsupportedMedia(fileExt: post.content.url.fileExtension),
            ),
            actionTitle: Text(t.openExternally),
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
