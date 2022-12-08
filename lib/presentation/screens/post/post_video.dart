import 'dart:async';

import 'package:async/async.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/provider/booru/post_headers_factory.dart';
import 'package:boorusphere/presentation/provider/cache.dart';
import 'package:boorusphere/presentation/provider/fullscreen_state.dart';
import 'package:boorusphere/presentation/provider/settings/content_setting_state.dart';
import 'package:boorusphere/presentation/screens/post/post_explicit_warning.dart';
import 'package:boorusphere/presentation/screens/post/post_placeholder_image.dart';
import 'package:boorusphere/presentation/screens/post/post_toolbox.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:boorusphere/presentation/utils/hooks/markmayneedrebuild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';

part 'post_video.g.dart';

Future<FileInfo> _fetchVideo(
  Ref ref,
  Post post,
) async {
  final headers = await ref.read(postHeadersFactoryProvider).build(post);
  return ref
      .read(cacheManagerProvider)
      .downloadFile(post.content.url, authHeaders: headers);
}

@riverpod
CancelableOperation<FileInfo> videoPlayerSource(
  VideoPlayerSourceRef ref,
  Post post,
) {
  final cancelable = CancelableOperation.fromFuture(_fetchVideo(ref, post));

  ref.onDispose(() {
    if (!cancelable.isCompleted) {
      cancelable.cancel();
    }
  });

  return cancelable;
}

@riverpod
Future<VideoPlayerController> videoPlayerController(
  VideoPlayerControllerRef ref,
  Post post,
) async {
  VideoPlayerController controller;

  final cache = ref.watch(cacheManagerProvider);
  final fromCache = await cache.getFileFromCache(post.content.url);
  final option = VideoPlayerOptions(mixWithOthers: true);
  if (fromCache != null) {
    controller = VideoPlayerController.file(
      fromCache.file,
      videoPlayerOptions: option,
    );
  } else {
    final fetcher = ref.watch(videoPlayerSourceProvider(post));
    final fromNet = await fetcher.value;
    controller = VideoPlayerController.file(
      fromNet.file,
      videoPlayerOptions: option,
    );
  }

  ref.onDispose(() {
    controller.pause();
    controller.dispose();
  });

  return controller;
}

class PostVideo extends HookConsumerWidget {
  const PostVideo({
    super.key,
    required this.post,
    this.isFromHome = false,
    this.heroTag,
  });

  final Post post;
  final bool isFromHome;
  final Object? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerController = ref.watch(videoPlayerControllerProvider(post));
    final blurExplicitPost =
        ref.watch(contentSettingStateProvider.select((it) => it.blurExplicit));

    final isMounted = useIsMounted();
    final isBlur =
        useState(post.rating == PostRating.explicit && blurExplicitPost);

    final heroWidgetKey = useMemoized(GlobalKey.new);
    Widget asHero(Widget child) {
      return Hero(
        key: heroWidgetKey,
        tag: heroTag ?? post.id,
        child: child,
      );
    }

    final blurNoticeAnimator =
        useAnimationController(duration: const Duration(milliseconds: 200));
    useEffect(() {
      if (post.rating != PostRating.explicit || !blurExplicitPost) {
        return;
      }

      if (!isFromHome) {
        blurNoticeAnimator.forward();
        return;
      }

      Future.delayed(const Duration(milliseconds: 200), () {
        if (isMounted()) {
          blurNoticeAnimator.forward();
        }
      });
    }, []);

    return Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        if (isBlur.value)
          asHero(AspectRatio(
            aspectRatio: post.aspectRatio,
            child: PostPlaceholderImage(
              post: post,
              shouldBlur: true,
            ),
          ))
        else
          asHero(
            Center(
              child: AspectRatio(
                aspectRatio: post.aspectRatio,
                child: playerController.maybeWhen(
                  data: (controller) => Stack(
                    fit: StackFit.passthrough,
                    children: [
                      PostPlaceholderImage(
                        post: post,
                        shouldBlur: false,
                      ),
                      VideoPlayer(controller),
                    ],
                  ),
                  orElse: () => PostPlaceholderImage(
                    post: post,
                    shouldBlur: false,
                  ),
                ),
              ),
            ),
          ),
        _Toolbox(
          post: post,
          controllerAsync: isBlur.value ? null : playerController,
          disableProgressBar: isBlur.value,
        ),
        if (post.rating == PostRating.explicit && blurExplicitPost)
          FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: blurNoticeAnimator,
                curve: Curves.easeInCubic,
              ),
            ),
            child: Center(
              child: PostExplicitWarningCard(
                onConfirm: () {
                  blurNoticeAnimator.reverse();
                  isBlur.value = false;
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _Toolbox extends HookConsumerWidget {
  const _Toolbox({
    required this.post,
    this.controllerAsync,
    this.disableProgressBar = false,
  });

  final Post post;
  final AsyncValue<VideoPlayerController>? controllerAsync;
  final bool disableProgressBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = controllerAsync?.asData?.value;
    final isMuted =
        ref.watch(contentSettingStateProvider.select((it) => it.videoMuted));
    final fullscreen = ref.watch(fullscreenStateProvider);
    final markMayNeedRebuild = useMarkMayNeedRebuild();
    final playState = useState(true);
    final isMounted = useIsMounted();
    final showToolbox = useState(true);

    onPlayStateChanged() {
      if (controller != null) {
        playState.value ? controller.play() : controller.pause();
      }
    }

    useEffect(() {
      playState.addListener(onPlayStateChanged);
      return () {
        playState.removeListener(onPlayStateChanged);
      };
    }, [controller]);

    autoHideToolbox() {
      Future.delayed(const Duration(seconds: 2), () {
        if (isMounted()) showToolbox.value = false;
      });
    }

    useEffect(() {
      controllerAsync?.whenData((it) {
        it.setLooping(true);
        it.initialize().whenComplete(() {
          onFirstFrame() {
            markMayNeedRebuild();
            it.removeListener(onFirstFrame);
          }

          it.addListener(onFirstFrame);
          it.setVolume(isMuted ? 0 : 1);
          if (playState.value) {
            it.play();
            autoHideToolbox();
          }
        });
      });
    }, [controllerAsync]);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        showToolbox.value = !showToolbox.value;
      },
      child: Container(
        color: showToolbox.value ? Colors.black38 : Colors.transparent,
        child: !showToolbox.value
            ? const SizedBox.expand()
            : Stack(
                alignment: Alignment.center,
                children: [
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.white,
                      iconSize: 72,
                      icon: Icon(
                        playState.value
                            ? Icons.pause_outlined
                            : Icons.play_arrow,
                      ),
                      onPressed: () {
                        playState.value = !playState.value;
                      },
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            PostFavoriteButton(post: post),
                            PostDownloadButton(post: post),
                            IconButton(
                              padding: const EdgeInsets.all(16),
                              color: Colors.white,
                              onPressed: () async {
                                final mute = await ref
                                    .read(contentSettingStateProvider.notifier)
                                    .toggleVideoPlayerMute();
                                await controller?.setVolume(mute ? 0 : 1);
                              },
                              icon: Icon(
                                isMuted ? Icons.volume_mute : Icons.volume_up,
                              ),
                            ),
                            PostDetailsButton(post: post),
                            IconButton(
                              color: Colors.white,
                              icon: Icon(
                                fullscreen
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen_outlined,
                              ),
                              padding: const EdgeInsets.all(16),
                              onPressed: () {
                                ref
                                    .read(fullscreenStateProvider.notifier)
                                    .toggle(
                                        shouldLandscape:
                                            post.width > post.height);
                                autoHideToolbox();
                              },
                            ),
                          ],
                        ),
                        _Progress(
                          controller: controller,
                          enabled: !disableProgressBar,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({this.controller, this.enabled = true});

  final VideoPlayerController? controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final player = controller;

    if (!enabled) {
      return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: LinearProgressIndicator(
          value: 0,
          backgroundColor: Colors.white.withAlpha(20),
        ),
      );
    }

    if (player == null || !player.value.isInitialized) {
      return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.redAccent.shade700,
          ),
          backgroundColor: Colors.white.withAlpha(20),
        ),
      );
    }

    return VideoProgressIndicator(
      player,
      colors: VideoProgressColors(
        playedColor: Colors.redAccent.shade700,
        backgroundColor: Colors.white.withAlpha(20),
      ),
      allowScrubbing: true,
      padding: const EdgeInsets.only(top: 16, bottom: 16),
    );
  }
}
