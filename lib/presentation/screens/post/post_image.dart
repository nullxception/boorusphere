import 'dart:math';

import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/booru/post_headers_factory.dart';
import 'package:boorusphere/presentation/provider/fullscreen_state.dart';
import 'package:boorusphere/presentation/provider/settings/content_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/entity/booru_rating.dart';
import 'package:boorusphere/presentation/screens/post/post_explicit_warning.dart';
import 'package:boorusphere/presentation/screens/post/post_placeholder_image.dart';
import 'package:boorusphere/presentation/screens/post/quickbar.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/utils/extensions/images.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:boorusphere/utils/extensions/number.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostImage extends HookConsumerWidget {
  const PostImage({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentSetting = ref.watch(contentSettingStateProvider);
    final shouldBlurExplicit =
        contentSetting.blurExplicit && !contentSetting.blurTimelineOnly;
    final headers = ref.watch(postHeadersFactoryProvider(post));
    final isBlur = useState(post.rating.isExplicit && shouldBlurExplicit);
    final zoomAnimator =
        useAnimationController(duration: const Duration(milliseconds: 150));
    // GlobalKey to keep the hero state across blur and ExtendedImage's loadState changes
    final imageHeroKey = useMemoized(GlobalKey.new);
    final blurNoticeAnimator =
        useAnimationController(duration: const Duration(milliseconds: 200));

    useEffect(() {
      if (post.rating != BooruRating.explicit || !shouldBlurExplicit) {
        return;
      }

      Future(() {
        if (context.mounted) {
          blurNoticeAnimator.forward();
        }
      });
    }, []);

    final deviceRatio = context.mediaQuery.size.aspectRatio;
    final imageRatio = post.aspectRatio;
    final scaleRatio = deviceRatio < imageRatio
        ? imageRatio / deviceRatio
        : deviceRatio / imageRatio;

    return GestureDetector(
      onTap: () {
        ref.read(fullscreenStateProvider.notifier).toggle();
      },
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.passthrough,
        children: [
          if (isBlur.value)
            Hero(
              key: imageHeroKey,
              tag: post.heroTag,
              child: PostPlaceholderImage(
                post: post,
                shouldBlur: true,
              ),
            )
          else
            ExtendedImage.network(
              contentSetting.loadOriginal
                  ? post.originalFile
                  : post.content.url,
              headers: headers,
              fit: BoxFit.contain,
              mode: ExtendedImageMode.gesture,
              initGestureConfigHandler: (state) {
                return GestureConfig(
                  maxScale: scaleRatio * 5,
                  inPageView: true,
                );
              },
              handleLoadingProgress: true,
              loadStateChanged: (state) {
                return _PostImageStatus(
                  key: ValueKey(post.id),
                  state: state,
                  child: Hero(
                    key: imageHeroKey,
                    tag: post.heroTag,
                    child: state.isCompleted
                        ? state.completedWidget
                        : PostPlaceholderImage(
                            post: post,
                            shouldBlur: false,
                            headers: headers,
                          ),
                  ),
                );
              },
              onDoubleTap: (state) async {
                if (zoomAnimator.isAnimating) {
                  // It should be impossible for human to do quadruple-tap
                  // at 150 ms. Still, better than no guards at all
                  return;
                }

                final downOffset = state.pointerDownPosition;
                final begin = state.gestureDetails?.totalScale ?? 1;
                final animation = zoomAnimator.drive(
                  Tween<double>(
                    begin: begin,
                    end: begin == 1 ? max(2, scaleRatio) : 1.0,
                  ),
                );

                void onAnimating() {
                  state.handleDoubleTap(
                      scale: animation.value, doubleTapPosition: downOffset);
                }

                if (zoomAnimator.isCompleted) {
                  zoomAnimator.reset();
                }
                animation.addListener(onAnimating);
                await zoomAnimator.forward();
                animation.removeListener(onAnimating);
              },
            ),
          if (post.rating.isExplicit && shouldBlurExplicit)
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
      ),
    );
  }
}

class _PostImageStatus extends StatelessWidget {
  const _PostImageStatus({
    super.key,
    required this.child,
    required this.state,
  });

  final Widget child;
  final ExtendedImageState state;

  @override
  Widget build(BuildContext context) {
    final loadPercent = state.isCompleted
        ? 100
        : state.loadingProgress?.progressPercentage ?? 0;
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned(
          bottom: context.mediaQuery.viewInsets.bottom +
              kBottomNavigationBarHeight +
              32,
          child: AnimatedScale(
            duration: kThemeChangeDuration,
            curve: Curves.easeInOutCubic,
            scale: state.isCompleted ? 0 : 1,
            child: state.isFailed
                ? QuickBar.action(
                    title: Text(context.t.loadImageFailed),
                    actionTitle: Text(context.t.retry),
                    onPressed: state.reLoadImage,
                  )
                : QuickBar.progress(
                    title: loadPercent > 1 ? Text('$loadPercent%') : null,
                    progress: state.isCompleted
                        ? 1
                        : state.loadingProgress?.progressRatio,
                  ),
          ),
        ),
      ],
    );
  }
}
