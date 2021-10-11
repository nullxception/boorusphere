import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/booru_post.dart';
import '../../provider/video_player.dart';
import '../containers/post_detail.dart';

class PostVideoDisplay extends HookConsumerWidget {
  const PostVideoDisplay({Key? key, required this.booru}) : super(key: key);

  final BooruPost booru;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerPersist = ref.watch(videoPlayerProvider);
    final controller = useMemoized(() {
      final theme = Theme.of(context);
      final controller = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          looping: true,
          aspectRatio: booru.width / booru.height,
          allowedScreenSleep: false,
          showPlaceholderUntilPlay: true,
          autoDetectFullscreenDeviceOrientation: true,
          fit: BoxFit.contain,
          placeholder: CachedNetworkImage(
            fit: BoxFit.contain,
            imageUrl: booru.thumbnail,
            filterQuality: FilterQuality.high,
          ),
          controlsConfiguration: BetterPlayerControlsConfiguration(
            showControlsOnInitialize: false,
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
      controller.addEventsListener((ev) {
        switch (ev.betterPlayerEventType) {
          case BetterPlayerEventType.initialized:
            controller.setVolume(playerPersist.mute ? 0 : 1);
            break;
          case BetterPlayerEventType.setVolume:
            playerPersist.mute =
                controller.videoPlayerController?.value.volume == 0;
            break;
          default:
        }
      });
      return controller;
    });

    return BetterPlayer(controller: controller);
  }
}
