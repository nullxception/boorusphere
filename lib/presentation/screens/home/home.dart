import 'package:async/async.dart';
import 'package:boorusphere/presentation/screens/home/content.dart';
import 'package:boorusphere/presentation/screens/home/controller.dart';
import 'package:boorusphere/presentation/screens/home/drawer.dart';
import 'package:boorusphere/presentation/screens/home/search/controller.dart';
import 'package:boorusphere/presentation/widgets/styled_overlay_region.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchBar = ref.watch(searchBarController);
    final drawerFocused = useState(false);
    final atHomeScreen = !drawerFocused.value && !searchBar.isOpen;
    final isMounted = useIsMounted();
    final allowPop = useState(false);
    const maybePopTimeout = Duration(seconds: 1);
    final maybePopTimer = useMemoized(
      () => RestartableTimer(maybePopTimeout, () {
        if (isMounted()) allowPop.value = false;
      }),
    );
    clearMaybePop() {
      allowPop.value = false;
      maybePopTimer.cancel();
    }

    return Scaffold(
      extendBody: true,
      body: StyledOverlayRegion(
        child: WillPopScope(
          onWillPop: () async {
            if (!isMounted()) return true;

            if (!atHomeScreen) {
              maybePopTimer.cancel();
              context.scaffoldMessenger.hideCurrentSnackBar();
              if (searchBar.isOpen) {
                searchBar.close();
              }
              return false;
            }

            if (!allowPop.value) {
              allowPop.value = true;
              context.scaffoldMessenger.showSnackBar(const SnackBar(
                content: Text('Press back again to exit'),
                duration: maybePopTimeout,
              ));
              maybePopTimer.cancel();
              maybePopTimer.reset();
              return false;
            }

            return true;
          },
          child: _SlidableContainer(
            edgeDragWidth: atHomeScreen ? context.mediaQuery.size.width : 0,
            onSlideStatus: (status) {
              final focused = status != AnimationStatus.dismissed;
              drawerFocused.value = focused;
              if (focused) {
                clearMaybePop();
                context.scaffoldMessenger.hideCurrentSnackBar();
              }
            },
            body: const HomeContent(),
          ),
        ),
      ),
    );
  }
}

class _SlidableContainer extends HookConsumerWidget {
  const _SlidableContainer({
    required this.body,
    this.edgeDragWidth,
    this.onSlideStatus,
  });

  final Widget body;
  final double? edgeDragWidth;
  final void Function(AnimationStatus open)? onSlideStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slidingDrawer = ref.watch(slidingDrawerController);
    final animator =
        useAnimationController(duration: const Duration(milliseconds: 300));
    final tween = useMemoized(
        () => CurveTween(curve: Curves.easeInOutSine).animate(animator),
        [animator]);
    final maxDrawerWidth =
        (context.mediaQuery.size.width).clamp(0.0, 410.0) - 84;
    final canBeDragged = useState(true);

    final animationListener = useCallback(() {
      if (animator.isAnimating) return;

      onSlideStatus?.call(animator.status);
    }, []);

    useEffect(() {
      slidingDrawer.setAnimator(animator);
      animator.addListener(animationListener);
      return () {
        animator.removeListener(animationListener);
      };
    }, []);

    return GestureDetector(
      onHorizontalDragStart: (details) {
        final dragWidth = edgeDragWidth ?? context.mediaQuery.size.width / 2;
        final dx = details.globalPosition.dx;
        final isOpen = animator.isDismissed && dx < dragWidth;
        final isClose = animator.isCompleted && dx > dragWidth;
        // ignore when gesture started on the edge to avoid conflict
        // with system back gesture
        if (dx < 24) {
          canBeDragged.value = false;
          return;
        }

        canBeDragged.value = isOpen || isClose;
      },
      onHorizontalDragUpdate: (details) {
        if (!canBeDragged.value) return;

        final delta = details.primaryDelta;
        if (delta == null) return;

        animator.value += delta / maxDrawerWidth;
      },
      onHorizontalDragEnd: (details) async {
        if (animator.isCompleted || animator.isDismissed) return;

        if (details.velocity.pixelsPerSecond.dx.abs() >= 365) {
          final visualVelocity = details.velocity.pixelsPerSecond.dx /
              context.mediaQuery.size.width;

          await animator.fling(velocity: visualVelocity);
        } else if (animator.value < 0.5) {
          await animator.reverse();
        } else {
          await animator.forward();
        }
      },
      child: AnimatedBuilder(
        animation: tween,
        child: Material(
          color: context.theme.scaffoldBackgroundColor,
          child: body,
        ),
        builder: (context, child) {
          final slide = maxDrawerWidth * tween.value;
          return Stack(
            children: [
              Transform(
                transform: Matrix4.identity()
                  ..setTranslationRaw(
                      (1 - tween.value) * (maxDrawerWidth / 2), 0, 0)
                  ..translate(slide - maxDrawerWidth),
                alignment: Alignment.centerLeft,
                child: HomeDrawer(maxWidth: maxDrawerWidth),
              ),
              Transform.translate(
                offset: Offset(slide, 0),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: animator.isCompleted ? slidingDrawer.close : null,
                  child: IgnorePointer(
                    ignoring: animator.isCompleted,
                    child: child,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
