import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/post.dart';
import '../../../providers/fullscreen.dart';
import '../../../providers/settings/blur_explicit_post.dart';
import '../../utils/extensions/number.dart';
import 'post_explicit_warning.dart';
import 'post_placeholder_image.dart';
import 'quickbar.dart';

class PostImageDisplay extends HookConsumerWidget {
  const PostImageDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blurExplicitPost = ref.watch(blurExplicitPostProvider);
    final zoomController =
        useAnimationController(duration: const Duration(milliseconds: 150));
    final zoomAnimation = useState<Animation<double>?>(null);
    final zoomStateCallback = useState<VoidCallback?>(null);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        ref.read(fullscreenProvider.notifier).toggle();
      },
      child: PostImageBlurExplicitView(
        post: post,
        shouldBlur: blurExplicitPost,
        children: ExtendedImage.network(
          post.contentFile,
          headers: {'Referer': post.postUrl},
          fit: BoxFit.contain,
          mode: ExtendedImageMode.gesture,
          initGestureConfigHandler: (state) => GestureConfig(inPageView: true),
          handleLoadingProgress: true,
          loadStateChanged: (state) {
            switch (state.extendedImageLoadState) {
              case LoadState.loading:
              case LoadState.failed:
                return PostImageStatusView(
                  post: post,
                  state: state,
                  shouldBlur: blurExplicitPost,
                );
              default:
                return state.completedWidget;
            }
          },
          onDoubleTap: (state) {
            final downOffset = state.pointerDownPosition;
            final begin = state.gestureDetails?.totalScale ?? 1;
            zoomAnimation.value?.removeListener(zoomStateCallback.value!);

            zoomController.stop();
            zoomController.reset();

            zoomStateCallback.value = () {
              state.handleDoubleTap(
                  scale: zoomAnimation.value?.value,
                  doubleTapPosition: downOffset);
            };
            zoomAnimation.value = zoomController
                .drive(Tween<double>(begin: begin, end: begin == 1 ? 2 : 1));
            zoomAnimation.value?.addListener(zoomStateCallback.value!);
            zoomController.forward();
          },
        ),
      ),
    );
  }
}

class PostImageBlurExplicitView extends HookWidget {
  const PostImageBlurExplicitView({
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
            ],
          )
        : children;
  }
}

class PostImageStatusView extends StatelessWidget {
  const PostImageStatusView({
    super.key,
    required this.post,
    required this.state,
    required this.shouldBlur,
  });

  final Post post;
  final ExtendedImageState state;
  final bool shouldBlur;

  @override
  Widget build(BuildContext context) {
    final isFailed = state.extendedImageLoadState == LoadState.failed;
    final progressPercentage = state.loadingProgress?.progressPercentage ?? 0;
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        PostPlaceholderImage(
          post: post,
          shouldBlur: shouldBlur && post.rating == PostRating.explicit,
        ),
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
