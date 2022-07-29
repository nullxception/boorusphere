import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../data/post.dart';
import '../../../providers/settings/blur_explicit_post.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../utils/extensions/string.dart';
import 'post_placeholder_image.dart';

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
        PostPlaceholderImage(
          url: post.previewFile,
          shouldBlur: shouldBlur && post.rating == PostRating.explicit,
        ),
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom,
          child: Transform.scale(
            scale: 0.9,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                color: context.theme.cardColor,
              ),
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                        '${post.contentFile.fileExtension} is not supported'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(elevation: 0),
                    onPressed: () {
                      launchUrlString(post.originalFile,
                          mode: LaunchMode.externalApplication);
                    },
                    child: const Text('Open externally'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
