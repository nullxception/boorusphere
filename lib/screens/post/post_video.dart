import 'dart:async';

import 'package:async/async.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../entity/post.dart';
import '../../hooks/markmayneedrebuild.dart';
import '../../services/download.dart';
import '../../services/fullscreen.dart';
import '../../source/settings/blur_explicit_post.dart';
import '../../source/settings/video_player.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../utils/extensions/number.dart';
import '../../widgets/download_dialog.dart';
import '../app_router.dart';
import 'post_explicit_warning.dart';
import 'post_placeholder_image.dart';

final _videoCacheProvider = Provider((_) => DefaultCacheManager());

final _fetcherProvider =
    Provider.family.autoDispose<CancelableOperation, String>((ref, arg) {
  final cache = ref.watch(_videoCacheProvider);
  final cancelable = CancelableOperation.fromFuture(cache.downloadFile(arg));

  ref.onDispose(() {
    if (!cancelable.isCompleted) {
      cancelable.cancel();
    }
  });

  return cancelable;
});

final _playerControllerProvider = FutureProvider.autoDispose
    .family<VideoPlayerController, String>((ref, arg) async {
  VideoPlayerController controller;

  final cache = ref.watch(_videoCacheProvider);
  final fromCache = await cache.getFileFromCache(arg);
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
  });

  final Post post;
  final bool isFromHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerController =
        ref.watch(_playerControllerProvider(post.contentFile));
    final blurExplicit = ref.watch(blurExplicitPostProvider);
    final isMounted = useIsMounted();
    final isBlur = useState(post.rating == PostRating.explicit && blurExplicit);

    final heroKey = useMemoized(GlobalKey.new);
    final asHero = useCallback<Widget Function(Widget)>((child) {
      return Hero(key: heroKey, tag: post.id, child: child);
    }, []);

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
    final downloader = ref.watch(downloadProvider);
    final downloadProgress = downloader.getProgressByURL(post.originalFile);
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

    final autoHideToolbox = useCallback(() {
      Future.delayed(const Duration(seconds: 2), () {
        if (isMounted()) showToolbox.value = false;
      });
    }, [key]);

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
                      iconSize: 72,
                      icon: Icon(
                        isPlaying ? Icons.pause_outlined : Icons.play_arrow,
                      ),
                      onPressed: () {
                        ref
                            .read(_playerPlayState.state)
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
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: downloadProgress.status.isDownloading
                                      ? downloadProgress.progress.ratio
                                      : 0,
                                ),
                                IconButton(
                                  padding: const EdgeInsets.all(16),
                                  icon: Icon(
                                      downloadProgress.status.isDownloaded
                                          ? Icons.download_done
                                          : Icons.download),
                                  onPressed: () {
                                    DownloaderDialog.show(
                                        context: context, post: post);
                                  },
                                  disabledColor: context.colorScheme.primary,
                                ),
                              ],
                            ),
                            IconButton(
                              padding: const EdgeInsets.all(16),
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
                            IconButton(
                              padding: const EdgeInsets.all(16),
                              icon: const Icon(Icons.info),
                              onPressed: () => context.router
                                  .push(PostDetailsRoute(post: post)),
                            ),
                            IconButton(
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
