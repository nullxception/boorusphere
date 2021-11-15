import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_view/photo_view.dart';

import '../containers/post.dart';

class PostImageDisplay extends ConsumerWidget {
  const PostImageDisplay({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFullscreen = ref.watch(postFullscreenProvider.state);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(isFullscreen.state
            ? SystemUiMode.edgeToEdge
            : SystemUiMode.immersive);
        isFullscreen.state = !isFullscreen.state;
      },
      child: PhotoView(
        minScale: PhotoViewComputedScale.contained,
        imageProvider: CachedNetworkImageProvider(url),
        loadingBuilder: (_, ev) => Center(
          child: SizedBox(
            width: 92,
            height: 92,
            child: CircularProgressIndicator(
              strokeWidth: 8,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withAlpha(200),
              ),
              value: ev != null && ev.expectedTotalBytes != null
                  ? ev.cumulativeBytesLoaded / (ev.expectedTotalBytes ?? 1)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
