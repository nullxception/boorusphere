import 'dart:async';

import 'package:async/async.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/hooks/markmayneedrebuild.dart';
import 'package:boorusphere/presentation/provider/booru/page.dart';
import 'package:boorusphere/presentation/provider/fullscreen.dart';
import 'package:boorusphere/presentation/provider/setting/post/blur_explicit.dart';
import 'package:boorusphere/presentation/provider/setting/video_player.dart';
import 'package:boorusphere/presentation/screens/post/post_explicit_warning.dart';
import 'package:boorusphere/presentation/screens/post/post_placeholder_image.dart';
import 'package:boorusphere/presentation/screens/post/post_toolbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

final _videoCacheProvider = Provider((_) => DefaultCacheManager());

final _fetcherProvider =
    Provider.family.autoDispose<CancelableOperation, Post>((ref, arg) {
  final cache = ref.watch(_videoCacheProvider);
  final pageCookies = ref.watch(BooruPage.cookieProvider).asString();
  final cancelable = CancelableOperation.fromFuture(cache.downloadFile(
    arg.content.url,
    authHeaders: {
      'Referer': arg.postUrl,
      'Cookie': pageCookies,
    },
  ));

  ref.onDispose(() {
    if (!cancelable.isCompleted) {
      cancelable.cancel();
    }
  });

  return cancelable;
});

final _playerControllerProvider = FutureProvider.autoDispose
    .family<VideoPlayerController, Post>((ref, arg) async {
  VideoPlayerController controller;

  final cache = ref.watch(_videoCacheProvider);
  final fromCache = await cache.getFileFromCache(arg.content.url);
  final option = VideoPlayerOptions(mixWithOthers: true);
  if (fromCache != null) {
    controller = VideoPlayerController.file(
      fromCache.file,
      videoPlayerOptions: option,
    );
  } else {
    final fetcher = ref.watch(_fetcherProvider(arg));
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
});

final _playerPlayState = StateProvider((ref) => false);

class PostVideoDisplay extends HookConsumerWidget {
  const PostVideoDisplay({
    super.key,
    required this.post,
    this.isFromHome = false,
    this.heroKey,
  });

  final Post post;
  final bool isFromHome;
  final Object? heroKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerController = ref.watch(_playerControllerProvider(post));
    final blurExplicit = ref.watch(blurExplicitPostProvider);
    final isMounted = useIsMounted();
    final isBlur = useState(post.rating == PostRating.explicit && blurExplicit);

    final heroWidgetKey = useMemoized(GlobalKey.new);
    Widget asHero(Widget child) {
      return Hero(
        key: heroWidgetKey,
        tag: heroKey ?? post.id,
        child: child,
      );
    }

    final blurNoticeAnimator =
        useAnimationController(duration: const Duration(milliseconds: 200));
    useEffect(() {
      if (post.rating != PostRating.explicit || !blurExplicit) {
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
          controllerAsync: playerController,
          disableProgressBar: isBlur.value,
        ),
        if (post.rating == PostRating.explicit && blurExplicit)
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
    final isMuted = ref.watch(videoPlayerMuteProvider);
    final fullscreen = ref.watch(fullscreenProvider);
    final markMayNeedRebuild = useMarkMayNeedRebuild();
    final playerMute = ref.watch(videoPlayerMuteProvider);
    final isPlaying = ref.watch(_playerPlayState);
    final isMounted = useIsMounted();
    final showToolbox = useState(true);

    ref.listen<bool>(_playerPlayState, (previous, next) {
      if (controller != null) {
        next ? controller.play() : controller.pause();
      }
    });

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
          it.setVolume(playerMute ? 0 : 1);
          if (isPlaying) {
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
                        isPlaying ? Icons.pause_outlined : Icons.play_arrow,
                      ),
                      onPressed: () {
                        ref
                            .read(_playerPlayState.notifier)
                            .update((state) => !isPlaying);
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
                                    .read(videoPlayerMuteProvider.notifier)
                                    .toggle();
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
                                ref.read(fullscreenProvider.notifier).toggle(
                                    shouldLandscape: post.width > post.height);
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
