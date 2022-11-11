import 'package:boorusphere/data/entity/post.dart';
import 'package:boorusphere/data/source/page.dart';
import 'package:boorusphere/presentation/provider/fullscreen.dart';
import 'package:boorusphere/presentation/provider/setting/post/blur_explicit.dart';
import 'package:boorusphere/presentation/provider/setting/post/load_original.dart';
import 'package:boorusphere/presentation/screens/post/post_explicit_warning.dart';
import 'package:boorusphere/presentation/screens/post/post_placeholder_image.dart';
import 'package:boorusphere/presentation/screens/post/quickbar.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:boorusphere/utils/extensions/number.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostImageDisplay extends HookConsumerWidget {
  const PostImageDisplay({
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
    final blurExplicit = ref.watch(blurExplicitPostProvider);
    final displayOriginal = ref.watch(loadOriginalPostProvider);
    final pageCookies =
        ref.watch(pageDataProvider.select((value) => value.cookies));
    final isBlur = useState(post.rating == PostRating.explicit && blurExplicit);
    final zoomAnimator =
        useAnimationController(duration: const Duration(milliseconds: 150));
    // GlobalKey to keep the hero state across blur and ExtendedImage's loadState changes
    final imageHeroKey = useMemoized(GlobalKey.new);
    final blurNoticeAnimator =
        useAnimationController(duration: const Duration(milliseconds: 200));
    final isMounted = useIsMounted();

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

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        ref.read(fullscreenProvider.notifier).toggle();
      },
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.passthrough,
        children: [
          if (isBlur.value)
            Hero(
              key: imageHeroKey,
              tag: post.id,
              child: PostPlaceholderImage(
                post: post,
                shouldBlur: true,
              ),
            )
          else
            ExtendedImage.network(
              displayOriginal ? post.originalFile : post.content.url,
              headers: {
                'Referer': post.postUrl,
                'Cookie': pageCookies,
              },
              fit: BoxFit.contain,
              mode: ExtendedImageMode.gesture,
              initGestureConfigHandler: (state) =>
                  GestureConfig(inPageView: true),
              handleLoadingProgress: true,
              loadStateChanged: (state) {
                return _PostImageStatus(
                  key: ValueKey(post.id),
                  state: state,
                  child: Hero(
                    key: imageHeroKey,
                    tag: heroKey ?? post.id,
                    child: LoadState.completed == state.extendedImageLoadState
                        ? state.completedWidget
                        : PostPlaceholderImage(post: post, shouldBlur: false),
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
                  Tween<double>(begin: begin, end: begin == 1 ? 2 : 1),
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
    final isFailed = state.extendedImageLoadState == LoadState.failed;
    final isDone = state.extendedImageLoadState == LoadState.completed;
    final loadPercent =
        isDone ? 100 : state.loadingProgress?.progressPercentage ?? 0;
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
            scale: state.extendedImageLoadState == LoadState.completed ? 0 : 1,
            child: isFailed
                ? QuickBar.action(
                    title: const Text('Failed to load image'),
                    actionTitle: const Text('Retry'),
                    onPressed: state.reLoadImage,
                  )
                : QuickBar.progress(
                    title: loadPercent > 1 ? Text('$loadPercent%') : null,
                    progress: isDone ? 1 : state.loadingProgress?.progressRatio,
                  ),
          ),
        ),
      ],
    );
  }
}
