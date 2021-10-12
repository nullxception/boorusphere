import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../model/booru_post.dart';
import 'post_error.dart';
import 'post_image.dart';
import 'post_video.dart';

class PostDisplay extends HookWidget {
  const PostDisplay({Key? key, required this.content}) : super(key: key);

  final BooruPost content;

  @override
  Widget build(BuildContext context) {
    final isFullscreen = useState(false);
    return GestureDetector(
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(isFullscreen.value
            ? SystemUiMode.edgeToEdge
            : SystemUiMode.immersive);
        isFullscreen.value = !isFullscreen.value;
      },
      child: Stack(
        alignment: AlignmentDirectional.center,
        fit: StackFit.passthrough,
        children: [
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
