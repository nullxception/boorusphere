import 'dart:async';

import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/provider/booru/post_headers_factory.dart';
import 'package:boorusphere/presentation/provider/fullscreen_state.dart';
import 'package:boorusphere/presentation/provider/settings/content_setting_state.dart';
import 'package:boorusphere/presentation/screens/post/hooks/video_post.dart';
import 'package:boorusphere/presentation/screens/post/post_explicit_warning.dart';
import 'package:boorusphere/presentation/screens/post/post_placeholder_image.dart';
import 'package:boorusphere/presentation/screens/post/post_toolbox.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:boorusphere/presentation/utils/hooks/markmayneedrebuild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

class PostVideo extends HookConsumerWidget {
  const PostVideo({
    super.key,
    required this.post,
    this.heroTag,
    required this.onToolboxVisibilityChange,
  });

  final Post post;
  final Object? heroTag;
  final void Function(bool visible) onToolboxVisibilityChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headers = ref.watch(postHeadersFactoryProvider(post));
    final videoPostData = useVideoPost(ref, post);
    final contentSettings = ref.watch(contentSettingStateProvider);
    final shouldBlurExplicit =
        contentSettings.blurExplicit && !contentSettings.blurTimelineOnly;
    final isMounted = useIsMounted();
    final shouldBlur = post.rating.isExplicit && shouldBlurExplicit;
    final isBlur = useState(shouldBlur);
    final blurNoticeAnimator =
        useAnimationController(duration: const Duration(milliseconds: 200));
    final showOverlay = useState(true);

    useEffect(() {
      Future(() {
        if (isMounted() && shouldBlur) {
          blurNoticeAnimator.forward();
        }
      });
    }, []);

    onVisibilityChange(bool value) {
      showOverlay.value = value;
      onToolboxVisibilityChange.call(value);
    }

    final controller = isBlur.value ? null : videoPostData.controller;
    final videoMuted =
        ref.watch(contentSettingStateProvider.select((it) => it.videoMuted));
    final fullscreen = ref.watch(fullscreenStateProvider);
    final markMayNeedRebuild = useMarkMayNeedRebuild();
    final isPlaying = useState(true);
    final hideTimer = useState<Timer?>(null);

    scheduleHide() {
      if (!isMounted()) return;
      hideTimer.value?.cancel();
      hideTimer.value = Timer(const Duration(seconds: 2), () {
        if (isMounted()) {
          onVisibilityChange.call(false);
        }
      });
    }

    useEffect(() {
      controller?.initialize().whenComplete(() async {
        onFirstFrame() {
          controller.removeListener(onFirstFrame);
          markMayNeedRebuild();
        }

        controller.addListener(onFirstFrame);
        await controller.setVolume(videoMuted ? 0 : 1);
        if (isPlaying.value && isMounted()) {
          await controller.play();
          scheduleHide();
        }
      });
    }, [controller]);

    return Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        Hero(
          key: ValueKey(post),
          tag: heroTag ?? post.id,
          child: Center(
            child: AspectRatio(
              aspectRatio: post.aspectRatio,
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  PostPlaceholderImage(
                    post: post,
                    headers: headers,
                    shouldBlur: isBlur.value,
                  ),
                  if (controller != null) VideoPlayer(controller),
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            onVisibilityChange.call(!showOverlay.value);
          },
          child: Container(
            color: showOverlay.value ? Colors.black38 : Colors.transparent,
            child: Visibility(
              visible: showOverlay.value,
              replacement: const SizedBox.expand(),
              child: SafeArea(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _PlayPauseOverlay(
                      isPlaying: isPlaying.value,
                      controller: controller,
                      onPlayChange: (value) {
                        isPlaying.value = value;
                        if (controller != null) {
                          scheduleHide();
                        }
                      },
                    ),
                    _ToolboxOverlay(
                      isPlaying: isPlaying.value,
                      controller: controller,
                      post: post,
                      isMuted: videoMuted,
                      isFullscreen: fullscreen,
                      disableProgressBar: isBlur.value,
                      onAutoHideRequest: scheduleHide,
                      onPlayChange: (value) {
                        isPlaying.value = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isBlur.value)
          FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: blurNoticeAnimator,
                curve: Curves.easeInCubic,
              ),
            ),
            child: Center(
              child: PostExplicitWarningCard(
                onConfirm: () async {
                  await blurNoticeAnimator.reverse();
                  isBlur.value = false;
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _ToolboxOverlay extends ConsumerWidget {
  const _ToolboxOverlay({
    required this.controller,
    required this.post,
    required this.isPlaying,
    required this.isMuted,
    required this.isFullscreen,
    required this.disableProgressBar,
    this.onAutoHideRequest,
    this.onPlayChange,
  });

  final bool isPlaying;
  final VideoPlayerController? controller;
  final Post post;
  final bool isMuted;
  final bool isFullscreen;
  final bool disableProgressBar;
  final void Function()? onAutoHideRequest;
  final void Function(bool value)? onPlayChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = this.controller;

    return Column(
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
                isFullscreen
                    ? Icons.fullscreen_exit
                    : Icons.fullscreen_outlined,
              ),
              padding: const EdgeInsets.all(16),
              onPressed: () {
                ref
                    .read(fullscreenStateProvider.notifier)
                    .toggle(shouldLandscape: post.width > post.height);
                onAutoHideRequest?.call();
              },
            ),
          ],
        ),
        _Progress(
          controller: controller,
          enabled: !disableProgressBar,
        ),
      ],
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({
    required this.isPlaying,
    required this.controller,
    required this.onPlayChange,
  });

  final bool isPlaying;
  final VideoPlayerController? controller;
  final void Function(bool value)? onPlayChange;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.black38,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: const EdgeInsets.all(8.0),
        color: Colors.white,
        iconSize: 72,
        icon: Icon(isPlaying ? Icons.pause_outlined : Icons.play_arrow),
        onPressed: () {
          if (controller != null) {
            onPlayChange?.call(!controller.value.isPlaying);
            controller.value.isPlaying ? controller.pause() : controller.play();
          } else {
            onPlayChange?.call(!isPlaying);
          }
        },
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
