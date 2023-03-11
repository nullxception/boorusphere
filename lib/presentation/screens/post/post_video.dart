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
    final source = useVideoPost(ref, post);
    final contentSettings = ref.watch(contentSettingStateProvider);
    final shouldBlurExplicit =
        contentSettings.blurExplicit && !contentSettings.blurTimelineOnly;
    final shouldBlur = post.rating.isExplicit && shouldBlurExplicit;
    final isBlur = useState(shouldBlur);
    final blurNoticeAnimator =
        useAnimationController(duration: const Duration(milliseconds: 200));
    final showOverlay = useState(true);

    useEffect(() {
      Future(() {
        if (context.mounted && shouldBlur) {
          blurNoticeAnimator.forward();
        }
      });
    }, []);

    onVisibilityChange(bool value) {
      showOverlay.value = value;
      onToolboxVisibilityChange.call(value);
    }

    final controller = isBlur.value ? null : source.controller;
    final videoMuted =
        ref.watch(contentSettingStateProvider.select((it) => it.videoMuted));
    final fullscreen = ref.watch(fullscreenStateProvider);
    final markMayNeedRebuild = useMarkMayNeedRebuild();
    final isPlaying = useState(true);
    final hideTimer = useState<Timer?>(null);

    scheduleHide() {
      if (!context.mounted) return;
      hideTimer.value?.cancel();
      hideTimer.value = Timer(const Duration(seconds: 2), () {
        if (context.mounted) {
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
        if (isPlaying.value && context.mounted) {
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
                      onPressed: () {
                        if (controller != null) {
                          isPlaying.value = !controller.value.isPlaying;
                          controller.value.isPlaying
                              ? controller.pause()
                              : controller.play();
                          scheduleHide();
                        } else {
                          isPlaying.value = !isPlaying.value;
                        }
                      },
                    ),
                    _ToolboxOverlay(
                      isPlaying: isPlaying.value,
                      source: source,
                      post: post,
                      isMuted: videoMuted,
                      isFullscreen: fullscreen,
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
    required this.post,
    required this.source,
    required this.isPlaying,
    required this.isMuted,
    required this.isFullscreen,
    this.onAutoHideRequest,
    this.onPlayChange,
  });

  final bool isPlaying;
  final VideoPostSource source;
  final Post post;
  final bool isMuted;
  final bool isFullscreen;
  final void Function()? onAutoHideRequest;
  final void Function(bool value)? onPlayChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                await source.controller?.setVolume(mute ? 0 : 1);
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
        _Progress(source: source),
      ],
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({
    required this.isPlaying,
    required this.onPressed,
  });

  final bool isPlaying;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
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
        onPressed: onPressed,
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.source});

  final VideoPostSource source;

  double _getProgressValue(VideoPostSource src) {
    return src.progress.downloaded / (src.progress.totalSize ?? 1);
  }

  bool _isDownloading(VideoPostSource src) {
    final value = _getProgressValue(src);
    return value > 0 && value < 1;
  }

  @override
  Widget build(BuildContext context) {
    final controller = source.controller;

    if (controller == null || !controller.value.isInitialized) {
      return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Stack(
          children: [
            if (_isDownloading(source))
              LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withAlpha(100),
                ),
                value: _getProgressValue(source),
                backgroundColor: Colors.transparent,
              ),
            LinearProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              backgroundColor: Colors.white.withAlpha(20),
            ),
          ],
        ),
      );
    }

    return VideoProgressIndicator(
      controller,
      colors: VideoProgressColors(
        playedColor: Colors.red,
        backgroundColor: Colors.white.withAlpha(20),
      ),
      allowScrubbing: true,
      padding: const EdgeInsets.only(top: 16, bottom: 16),
    );
  }
}
