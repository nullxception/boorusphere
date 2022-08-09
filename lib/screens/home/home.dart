import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../source/page.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../widgets/styled_overlay_region.dart';
import 'home_drawer.dart';
import 'page_status.dart';
import 'search/search.dart';
import 'sliver_thumbnails.dart';

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
      drawer: const HomeDrawer(),
      drawerEdgeDragWidth: atHomeScreen ? context.mediaQuery.size.width : 0,
      onDrawerChanged: (focusOnDrawer) {
        drawerFocused.value = focusOnDrawer;
        if (focusOnDrawer) {
          messenger.hideCurrentSnackBar();
        }
      },
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
          child: Stack(
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
