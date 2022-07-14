import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../containers/post.dart';

class PostImageDisplay extends HookConsumerWidget {
  const PostImageDisplay({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFullscreen = ref.watch(postFullscreenProvider.state);
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
        url,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.gesture,
        handleLoadingProgress: true,
        loadStateChanged: (state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              final prog = state.loadingProgress;
              return Center(
                child: SizedBox(
                  width: 92,
                  height: 92,
                  child: CircularProgressIndicator(
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withAlpha(200),
                    ),
                    value: prog != null && prog.expectedTotalBytes != null
                        ? prog.cumulativeBytesLoaded /
                            (prog.expectedTotalBytes ?? 1)
                        : null,
                  ),
                ),
              );
            case LoadState.failed:
              return SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Card(
                      color: Colors.black,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Failed to load image'),
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
                    )
                  ],
                ),
              );
            default:
              return Container(
                color: Colors.black,
                child: state.completedWidget,
              );
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
