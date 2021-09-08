import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/booru_post.dart';
import '../../provider/system_chrome.dart';
import 'post_error.dart';
import 'post_image.dart';
import 'post_video.dart';

class PostDisplay extends HookWidget {
  const PostDisplay({Key? key, required this.content}) : super(key: key);

  final BooruPost content;

  @override
  Widget build(BuildContext context) {
    final style = useProvider(systemChromeProvider);
    return GestureDetector(
      onTap: () => style.setFullScreen(enable: !style.isFullScreen),
      child: Stack(
        alignment: AlignmentDirectional.center,
        fit: StackFit.passthrough,
        children: [
          // Skip placeholder for video because it already handled by the player
          if (content.displayType != PostType.video)
            CachedNetworkImage(
              fit: BoxFit.contain,
              imageUrl: content.thumbnail,
              filterQuality: FilterQuality.high,
            ),
          if (content.displayType == PostType.photo)
            PostImageDisplay(url: content.src)
          else if (content.displayType == PostType.video)
            PostVideoDisplay(booru: content)
          else
            PostErrorDisplay(mime: content.mimeType)
        ],
      ),
    );
  }
}
