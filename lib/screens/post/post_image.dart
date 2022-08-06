import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../entity/post.dart';
import '../../services/fullscreen.dart';
import '../../settings/blur_explicit_post.dart';
import '../../utils/extensions/number.dart';
import 'post_explicit_warning.dart';
import 'post_placeholder_image.dart';
import 'quickbar.dart';

class PostImageDisplay extends HookConsumerWidget {
  const PostImageDisplay({
    super.key,
    required this.post,
    this.isFromHome = false,
  });

  final Post post;
  final bool isFromHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blurExplicit = ref.watch(blurExplicitPostProvider);
    final isBlur = useState(post.rating == PostRating.explicit && blurExplicit);
    final zoomAnimator =
        useAnimationController(duration: const Duration(milliseconds: 150));
    final zoomAnimation = useState<Animation<double>?>(null);
    final zoomStateCallback = useState<VoidCallback?>(null);
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
              post.contentFile,
              headers: {'Referer': post.postUrl},
              fit: BoxFit.contain,
              mode: ExtendedImageMode.gesture,
              initGestureConfigHandler: (state) =>
                  GestureConfig(inPageView: true),
              handleLoadingProgress: true,
              loadStateChanged: (state) {
                switch (state.extendedImageLoadState) {
                  case LoadState.loading:
                  case LoadState.failed:
                    return PostImageStatusView(
                      state: state,
                      child: Hero(
                        key: imageHeroKey,
                        tag: post.id,
                        child: PostPlaceholderImage(
                          post: post,
                          shouldBlur: false,
                        ),
                      ),
                    );
                  default:
                    return Hero(
                      key: imageHeroKey,
                      tag: post.id,
                      child: state.completedWidget,
                    );
                }
              },
              onDoubleTap: (state) {
                final downOffset = state.pointerDownPosition;
                final begin = state.gestureDetails?.totalScale ?? 1;
                zoomAnimation.value?.removeListener(zoomStateCallback.value!);

                zoomAnimator.stop();
                zoomAnimator.reset();

                zoomStateCallback.value = () {
                  state.handleDoubleTap(
                      scale: zoomAnimation.value?.value,
                      doubleTapPosition: downOffset);
                };
                zoomAnimation.value = zoomAnimator.drive(
                    Tween<double>(begin: begin, end: begin == 1 ? 2 : 1));
                zoomAnimation.value?.addListener(zoomStateCallback.value!);
                zoomAnimator.forward();
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

class PostImageStatusView extends StatelessWidget {
  const PostImageStatusView({
    super.key,
    required this.child,
    required this.state,
  });

  final Widget child;
  final ExtendedImageState state;

  @override
  Widget build(BuildContext context) {
    final isFailed = state.extendedImageLoadState == LoadState.failed;
    final progressPercentage = state.loadingProgress?.progressPercentage ?? 0;
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: isFailed
                ? QuickBar.action(
                    title: const Text('Failed to load image'),
                    actionTitle: const Text('Retry'),
                    onPressed: state.reLoadImage,
                  )
                : QuickBar.progress(
                    title: progressPercentage > 1
                        ? Text('$progressPercentage%')
                        : null,
                    progress: state.loadingProgress?.progressRatio,
                  ),
          ),
        ),
      ],
    );
  }
}
