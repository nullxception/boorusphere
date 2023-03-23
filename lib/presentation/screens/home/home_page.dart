import 'dart:async';

import 'package:async/async.dart';
import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/booru/page_state.dart';
import 'package:boorusphere/presentation/provider/booru/suggestion_state.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:boorusphere/presentation/screens/home/drawer/home_drawer.dart';
import 'package:boorusphere/presentation/screens/home/drawer/home_drawer_controller.dart';
import 'package:boorusphere/presentation/screens/home/home_content.dart';
import 'package:boorusphere/presentation/screens/home/search/search_bar.dart';
import 'package:boorusphere/presentation/screens/home/search/search_bar_controller.dart';
import 'package:boorusphere/presentation/screens/home/search_session.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/widgets/styled_overlay_region.dart';
import 'package:boorusphere/presentation/widgets/timeline/timeline_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

@RoutePage()
class HomePage extends ConsumerWidget {
  const HomePage({super.key, this.session});

  final SearchSession? session;

  Rect _timelineBoundary(BuildContext context) {
    final bottom = context.mediaQuery.padding.bottom + SearchBar.innerHeight;
    return Rect.fromLTRB(0, 0, 0, bottom);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedServerId =
        ref.read(serverSettingStateProvider.select((it) => it.lastActiveId));
    final session = this.session ?? SearchSession(serverId: savedServerId);

    return Scaffold(
      extendBody: true,
      body: StyledOverlayRegion(
        child: ProviderScope(
          overrides: [
            searchSessionProvider.overrideWith((ref) => session),
            pageStateProvider.overrideWith(
              () => PageState(session: session),
            ),
            suggestionStateProvider.overrideWith(
              () => SuggestionState(session: session),
            ),
            searchBarControllerProvider.overrideWith(
              (ref) => SearchBarController(ref, session: session),
            ),
            homeDrawerControllerProvider.overrideWith(
              (ref) => HomeDrawerController(),
            ),
            timelineControllerProvider.overrideWith(
              (ref) => TimelineController(
                scrollController: AutoScrollController(
                  viewportBoundaryGetter: () => _timelineBoundary(context),
                ),
                onLoadMore: () =>
                    ref.read(pageStateProvider.notifier).loadMore(),
              ),
            ),
          ],
          child: _Home(),
        ),
      ),
    );
  }
}

class _Home extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchBar = ref.watch(searchBarControllerProvider);
    final drawer = ref.watch(homeDrawerControllerProvider);
    final atHomeScreen = !drawer.isOpen && !searchBar.isOpen;
    final allowPop = useState(false);
    const maybePopTimeout = Duration(seconds: 1);
    final maybePopTimer = useMemoized(
      () => RestartableTimer(maybePopTimeout, () {
        if (context.mounted) allowPop.value = false;
      }),
    );
    clearMaybePop() {
      allowPop.value = false;
      maybePopTimer.cancel();
    }

    return WillPopScope(
      onWillPop: () async {
        if (!context.mounted) return true;

        if (drawer.isOpen || searchBar.isOpen) {
          maybePopTimer.cancel();
          context.scaffoldMessenger.hideCurrentSnackBar();
          if (drawer.isOpen) {
            unawaited(drawer.close());
            return false;
          } else if (searchBar.isOpen) {
            searchBar.close();
            return false;
          }
        }

        if (context.router.canPop()) return true;

        if (!allowPop.value) {
          allowPop.value = true;
          context.scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(context.t.retryPopBack),
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
          if (status != AnimationStatus.dismissed) {
            clearMaybePop();
            context.scaffoldMessenger.hideCurrentSnackBar();
          }
        },
        body: const HomeContent(),
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
      animator.addListener(animationListener);
      return () {
        animator.removeListener(animationListener);
      };
    }, []);

    final drawer = ref.watch(homeDrawerControllerProvider);
    useEffect(() {
      drawer.setAnimator(animator);
    }, [drawer]);

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
                  onTap: animator.isCompleted ? drawer.close : null,
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
