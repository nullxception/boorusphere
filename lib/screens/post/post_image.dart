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
  const PostImageDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blurExplicit = ref.watch(blurExplicitPostProvider);
    final isBlur = useState(post.rating == PostRating.explicit && blurExplicit);
    final zoomController =
        useAnimationController(duration: const Duration(milliseconds: 150));
    final zoomAnimation = useState<Animation<double>?>(null);
    final zoomStateCallback = useState<VoidCallback?>(null);

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
            PostPlaceholderImage(post: post, shouldBlur: true)
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
                      post: post,
                      state: state,
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
                zoomAnimation.value = zoomController.drive(
                    Tween<double>(begin: begin, end: begin == 1 ? 2 : 1));
                zoomAnimation.value?.addListener(zoomStateCallback.value!);
                zoomController.forward();
              },
            ),
          if (isBlur.value)
            Center(
              child: PostExplicitWarningCard(
                onConfirm: () {
                  isBlur.value = false;
                },
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
    required this.post,
    required this.state,
  });

  final Post post;
  final ExtendedImageState state;

  @override
  Widget build(BuildContext context) {
    final isFailed = state.extendedImageLoadState == LoadState.failed;
    final progressPercentage = state.loadingProgress?.progressPercentage ?? 0;
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        PostPlaceholderImage(post: post, shouldBlur: false),
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
