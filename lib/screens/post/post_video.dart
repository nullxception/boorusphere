import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../entity/post.dart';
import '../../../hooks/refresher.dart';
import '../../services/download.dart';
import '../../services/fullscreen.dart';
import '../../settings/blur_explicit_post.dart';
import '../../settings/video_player.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../utils/extensions/number.dart';
import '../../widgets/download_dialog.dart';
import 'post_detail.dart';
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
  if (fromCache != null) {
    controller = VideoPlayerController.file(fromCache.file);
  } else {
    final fetcher = ref.watch(_fetcherProvider(arg));
    final fromNet = await fetcher.value;
    controller = VideoPlayerController.file(fromNet.file);
  }

  ref.onDispose(() {
    controller.pause();
    controller.dispose();
  });

  return controller;
});

class PostVideoDisplay extends HookConsumerWidget {
  const PostVideoDisplay({super.key, required this.post});
  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blurExplicitPost = ref.watch(blurExplicitPostProvider);
    return PostVideoBlurExplicitView(
      post: post,
      shouldBlur: blurExplicitPost,
      children: PostVideoPlayer(post: post),
    );
  }
}

class PostVideoPlayer extends HookConsumerWidget {
  const PostVideoPlayer({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerController =
        ref.watch(_playerControllerProvider(post.contentFile));
    final playerMute = ref.watch(videoPlayerMuteProvider);
    final blurExplicitPost = ref.watch(blurExplicitPostProvider);
    final showToolbox = useState(true);
    final startPaused = useState(false);
    final refresh = useRefresher();
    final isMounted = useIsMounted();

    final autoHideToolbox = useCallback(() {
      Future.delayed(const Duration(seconds: 2), () {
        if (isMounted()) showToolbox.value = false;
      });
    }, [key]);

    final toggleFullscreen = useCallback(() {
      ref
          .read(fullscreenProvider.notifier)
          .toggle(shouldLandscape: post.width > post.height);
      autoHideToolbox();
    }, [key]);

    useEffect(() {
      playerController.whenData((it) {
        it.setLooping(true);
        it.initialize().whenComplete(() {
          onFirstFrame() {
            refresh();
            it.removeListener(onFirstFrame);
          }

          it.addListener(onFirstFrame);
          it.setVolume(playerMute ? 0 : 1);
          if (!startPaused.value) {
            it.play();
            autoHideToolbox();
          }
        });
      });
    }, [playerController]);

    useEffect(() {
      autoHideToolbox();
    }, [key]);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        ref.read(fullscreenProvider.notifier).toggle();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...playerController.maybeWhen(
            data: (controller) => [
              AspectRatio(
                aspectRatio: post.width / post.height,
                child: VideoPlayer(controller),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  showToolbox.value = !showToolbox.value;
                },
                child: showToolbox.value
                    ? _PlayerOverlay(
                        initialValue: !controller.value.isPlaying,
                        onTap: (isPaused) {
                          if (isPaused) {
                            controller.pause();
                          } else {
                            controller.play();
                            autoHideToolbox();
                          }
                        },
                      )
                    : Container(),
              ),
              if (showToolbox.value)
                _PlayerToolbox(
                  post: post,
                  controller: controller,
                  onFullscreenTap: (_) {
                    toggleFullscreen();
                  },
                )
            ],
            orElse: () => [
              AspectRatio(
                aspectRatio: post.aspectRatio,
                child: PostPlaceholderImage(
                  post: post,
                  shouldBlur:
                      blurExplicitPost && post.rating == PostRating.explicit,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  showToolbox.value = !showToolbox.value;
                },
                child: showToolbox.value
                    ? _PlayerOverlay(
                        onTap: (isPaused) {
                          startPaused.value = isPaused;
                          if (!isPaused) {
                            autoHideToolbox();
                          }
                        },
                      )
                    : Container(),
              ),
              if (showToolbox.value)
                _PlayerToolbox(
                  post: post,
                  onFullscreenTap: (_) {
                    toggleFullscreen();
                  },
                )
            ],
          ),
        ],
      ),
    );
  }
}

class PostVideoBlurExplicitView extends HookWidget {
  const PostVideoBlurExplicitView({
    super.key,
    required this.post,
    required this.shouldBlur,
    required this.children,
  });

  final Post post;
  final bool shouldBlur;
  final Widget children;

  @override
  Widget build(BuildContext context) {
    final isBlur = useState(post.rating == PostRating.explicit && shouldBlur);
    return isBlur.value
        ? Stack(
            alignment: Alignment.center,
            fit: StackFit.passthrough,
            children: [
              PostPlaceholderImage(post: post, shouldBlur: true),
              Center(
                child: PostExplicitWarningCard(onConfirm: () {
                  isBlur.value = false;
                }),
              ),
              _PlayerToolbox(post: post, disableProgressBar: true)
            ],
          )
        : children;
  }
}

class _PlayerOverlay extends HookWidget {
  const _PlayerOverlay({this.initialValue = false, this.onTap});

  final Function(bool isPlaying)? onTap;
  final bool initialValue;

  @override
  Widget build(BuildContext context) {
    final isPaused = useState(initialValue);

    return Container(
      color: Colors.black38,
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          isPaused.value = !isPaused.value;
          onTap?.call(isPaused.value);
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(16),
          child: Icon(
            !isPaused.value ? Icons.pause_outlined : Icons.play_arrow,
            size: 64.0,
          ),
        ),
      ),
    );
  }
}

class _PlayerToolbox extends HookConsumerWidget {
  const _PlayerToolbox({
    required this.post,
    this.controller,
    this.onFullscreenTap,
    this.disableProgressBar = false,
  });

  final Post post;
  final VideoPlayerController? controller;
  final Function(bool isFullscreen)? onFullscreenTap;
  final bool disableProgressBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMuted = ref.watch(videoPlayerMuteProvider);
    final downloader = ref.watch(downloadProvider);
    final downloadProgress = downloader.getProgressByURL(post.originalFile);
    final fullscreen = ref.watch(fullscreenProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top,
        16,
        MediaQuery.of(context).padding.bottom + 32,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
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
                    icon: Icon(downloadProgress.status.isDownloaded
                        ? Icons.download_done
                        : Icons.download),
                    onPressed: () {
                      DownloaderDialog.show(context: context, post: post);
                    },
                    disabledColor: context.colorScheme.primary,
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  final mute =
                      ref.read(videoPlayerMuteProvider.notifier).toggle();
                  controller?.setVolume(mute ? 0 : 1);
                },
                icon: Icon(
                  isMuted ? Icons.volume_mute : Icons.volume_up,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info),
                onPressed: () {
                  context.navigator.push(
                    MaterialPageRoute(
                      builder: (context) => PostDetailsPage(post: post),
                    ),
                  );
                },
              ),
              if (onFullscreenTap != null)
                IconButton(
                  icon: Icon(
                    fullscreen
                        ? Icons.fullscreen_exit
                        : Icons.fullscreen_outlined,
                  ),
                  onPressed: () {
                    onFullscreenTap?.call(fullscreen);
                  },
                ),
            ],
          ),
          if (!disableProgressBar) _PlayerProgress(controller: controller),
        ],
      ),
    );
  }
}

class _PlayerProgress extends StatelessWidget {
  const _PlayerProgress({this.controller});

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    return controller == null || !(controller?.value.isInitialized ?? false)
        ? Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.redAccent.shade700,
              ),
              backgroundColor: Colors.white.withAlpha(20),
            ),
          )
        : VideoProgressIndicator(
            controller!,
            colors: VideoProgressColors(
              playedColor: Colors.redAccent.shade700,
              backgroundColor: Colors.white.withAlpha(20),
            ),
            allowScrubbing: true,
            padding: const EdgeInsets.only(top: 16, bottom: 16),
          );
  }
}
