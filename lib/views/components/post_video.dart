import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../model/booru_post.dart';
import '../containers/post_detail.dart';

class PostVideoDisplay extends HookWidget {
  const PostVideoDisplay({Key? key, required this.booru}) : super(key: key);

  final BooruPost booru;

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(() {
      final theme = Theme.of(context);
      return BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          looping: true,
          aspectRatio: booru.width / booru.height,
          allowedScreenSleep: false,
          showPlaceholderUntilPlay: true,
          autoDetectFullscreenDeviceOrientation: true,
          placeholder: CachedNetworkImage(
            fit: BoxFit.contain,
            imageUrl: booru.thumbnail,
            filterQuality: FilterQuality.high,
          ),
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableSkips: false,
            enableProgressText: false,
            enableQualities: false,
            enableSubtitles: false,
            enableAudioTracks: false,
            overflowModalColor: theme.cardTheme.color ?? Colors.grey.shade900,
            overflowModalTextColor:
                theme.textTheme.subtitle1?.color ?? Colors.grey.shade100,
            overflowMenuCustomItems: [
              BetterPlayerOverflowMenuItem(
                Icons.info,
                'Post Details',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PostDetails(id: booru.id)),
                ),
              )
            ],
          ),
        ),
        betterPlayerDataSource: BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          booru.displaySrc,
          cacheConfiguration:
              const BetterPlayerCacheConfiguration(useCache: true),
        ),
      );
    });

    return BetterPlayer(controller: controller);
  }
}
