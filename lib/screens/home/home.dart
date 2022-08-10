import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../entity/page_option.dart';
import '../../settings/active_server.dart';
import '../../settings/theme.dart';
import '../../source/page.dart';
import '../../source/server.dart';
import '../../source/version.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../widgets/favicon.dart';
import '../../widgets/styled_overlay_region.dart';
import 'page_status.dart';
import 'search/search.dart';
import 'sliver_thumbnails.dart';

part 'controller.dart';
part 'drawer.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messenger = context.scaffoldMessenger;
    final scrollController = useMemoized(() {
      return AutoScrollController(axis: Axis.vertical);
    });
    final searchBar = ref.watch(searchBarController);
    final pageState = ref.watch(pageStateProvider);
    final pageData = ref.watch(pageDataProvider);
    final drawerFocused = useState(false);
    final atHomeScreen = !drawerFocused.value && !searchBar.isOpen;

    final loadMoreCall = useCallback(() {
      if (scrollController.position.extentAfter < 200) {
        ref.read(pageDataProvider).loadMore();
      }
    }, [scrollController]);

    useEffect(() {
      scrollController.addListener(loadMoreCall);
      return () => scrollController.removeListener(loadMoreCall);
    }, [scrollController]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageState.whenOrNull(error: (error, stackTrace) {
        if (scrollController.position.extentAfter < 300) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
          );
        }
      });
    });

    return Scaffold(
      extendBody: true,
      body: StyledOverlayRegion(
        child: DoubleBack(
          condition: atHomeScreen,
          waitForSecondBackPress: 2,
          onConditionFail: () {
            messenger.hideCurrentSnackBar();
            if (searchBar.isOpen) {
              searchBar.close();
            }
          },
          onFirstBackPress: (context) {
            messenger.showSnackBar(const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ));
          },
          child: _SlidableContainer(
            edgeDragWidth: atHomeScreen ? context.mediaQuery.size.width : 0,
            onSlide: (open) {
              drawerFocused.value = open;
              if (open) {
                messenger.hideCurrentSnackBar();
              }
            },
            body: Stack(
              alignment: Alignment.center,
              children: [
                CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                          10, context.mediaQuery.viewPadding.top + 10, 10, 10),
                      sliver: SliverThumbnails(
                        autoScrollController: scrollController,
                        onTap: (index) {
                          messenger.removeCurrentSnackBar();
                        },
                      ),
                    ),
                    if (pageData.posts.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.only(
                          bottom:
                              context.mediaQuery.viewPadding.bottom * 1.8 + 92,
                        ),
                        sliver: const SliverToBoxAdapter(child: PageStatus()),
                      )
                  ],
                ),
                if (pageData.posts.isEmpty) const PageStatus(),
                const _EdgeShadow(),
                SearchableView(scrollController: scrollController),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EdgeShadow extends StatelessWidget {
  const _EdgeShadow();

  @override
  Widget build(BuildContext context) {
    final tint = context.theme.scaffoldBackgroundColor;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: SizedBox(
          height: context.mediaQuery.padding.top * 1.8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomLeft,
                colors: [tint.withOpacity(0.8), tint.withOpacity(0)],
              ),
            ),
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
    this.onSlide,
  });

  final Widget body;
  final double? edgeDragWidth;
  final void Function(bool open)? onSlide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slidingDrawer = ref.watch(slidingDrawerController);
    final animator = useAnimationController(duration: kThemeAnimationDuration);
    final maxDrawerWidth = context.mediaQuery.size.width - 84;
    final canBeDragged = useState(true);
    final drawerKey = useMemoized(GlobalKey.new);

    final animationListener = useCallback(() {
      if (animator.isAnimating) return;

      onSlide?.call(animator.isCompleted);
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
        final isOpen =
            animator.isDismissed && details.globalPosition.dx < dragWidth;
        final isClose =
            animator.isCompleted && details.globalPosition.dx > dragWidth;
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
        animation: animator,
        child: body,
        builder: (context, child) {
          final slide = maxDrawerWidth * animator.value;
          return Stack(
            children: [
              Transform(
                transform: Matrix4.identity()
                  ..setTranslationRaw(
                      (1 - animator.value) * (maxDrawerWidth / 2), 0, 0)
                  ..translate(slide - maxDrawerWidth),
                alignment: Alignment.centerLeft,
                child: _Drawer(key: drawerKey, maxWidth: maxDrawerWidth),
              ),
              Transform.translate(
                offset: Offset(slide, 0),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: animator.isCompleted ? slidingDrawer.close : null,
                  child: IgnorePointer(
                    ignoring: animator.isCompleted,
                    child: Material(
                      color: context.theme.scaffoldBackgroundColor,
                      child: child,
                    ),
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
