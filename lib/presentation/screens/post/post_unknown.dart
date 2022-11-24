import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/settings/content_setting_state.dart';
import 'package:boorusphere/presentation/screens/post/post_ext.dart';
import 'package:boorusphere/presentation/screens/post/post_placeholder_image.dart';
import 'package:boorusphere/presentation/screens/post/quickbar.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PostUnknown extends HookConsumerWidget {
  const PostUnknown({
    super.key,
    required this.post,
    this.heroTag,
  });

  final Post post;
  final Object? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blurExplicitPost =
        ref.watch(contentSettingStateProvider.select((it) => it.blurExplicit));
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        Hero(
          tag: heroTag ?? post.heroTag,
          child: PostPlaceholderImage(
            post: post,
            shouldBlur: blurExplicitPost && post.rating == PostRating.explicit,
          ),
        ),
        Positioned(
          bottom: context.mediaQuery.viewInsets.bottom +
              kBottomNavigationBarHeight +
              32,
          child: QuickBar.action(
            title: Text(
              context.t
                  .unsupportedMedia(fileExt: post.content.url.fileExtension),
            ),
            actionTitle: Text(context.t.openExternally),
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
