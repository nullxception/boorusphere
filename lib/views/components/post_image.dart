import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/booru_post.dart';
import '../../provider/settings/blur_explicit_post.dart';
import '../containers/post.dart';
import 'post_placeholder_image.dart';

class PostImageDisplay extends HookConsumerWidget {
  const PostImageDisplay({super.key, required this.booru});

  final BooruPost booru;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFullscreen = ref.watch(postFullscreenProvider.state);
    final blurExplicitPost = ref.watch(blurExplicitPostProvider);
    final zoomController =
        useAnimationController(duration: const Duration(milliseconds: 150));
    final zoomAnimation = useState<Animation<double>?>(null);
    final zoomStateCallback = useState<VoidCallback?>(null);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(isFullscreen.state
            ? SystemUiMode.edgeToEdge
            : SystemUiMode.immersive);
        isFullscreen.state = !isFullscreen.state;
      },
      child: ExtendedImage.network(
        booru.displaySrc,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.gesture,
        initGestureConfigHandler: (state) => GestureConfig(inPageView: true),
        handleLoadingProgress: true,
        loadStateChanged: (state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              return PostImageLoadingView(
                booru: booru,
                state: state,
                shouldBlur: blurExplicitPost,
              );
            case LoadState.failed:
              return PostImageFailedView(
                booru: booru,
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
    );
  }
}

class PostImageFailedView extends StatelessWidget {
  const PostImageFailedView({
    super.key,
    required this.booru,
    required this.state,
    required this.shouldBlur,
  });

  final BooruPost booru;
  final ExtendedImageState state;
  final bool shouldBlur;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      fit: StackFit.passthrough,
      children: [
        PostPlaceholderImage(
          url: booru.thumbnail,
          shouldBlur: shouldBlur && booru.rating == PostRating.explicit,
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                color: Colors.black38,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          state.reLoadImage();
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PostImageLoadingView extends StatelessWidget {
  const PostImageLoadingView({
    super.key,
    required this.booru,
    required this.state,
    this.shouldBlur = false,
  });

  final BooruPost booru;
  final ExtendedImageState state;
  final bool shouldBlur;

  double calcProgress(ImageChunkEvent? chunk) =>
      chunk != null && chunk.expectedTotalBytes != null
          ? chunk.cumulativeBytesLoaded / (chunk.expectedTotalBytes ?? 1)
          : 0;

  int calcPercentage(ImageChunkEvent? chunk) =>
      (100 * calcProgress(chunk)).round();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      fit: StackFit.passthrough,
      children: [
        PostPlaceholderImage(
          url: booru.thumbnail,
          shouldBlur: shouldBlur && booru.rating == PostRating.explicit,
        ),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        valueColor: const AlwaysStoppedAnimation(
                          Colors.white54,
                        ),
                        value: calcProgress(state.loadingProgress),
                      ),
                    ),
                    Text(
                      '${calcPercentage(state.loadingProgress)}%',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
