import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../source/page.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../widgets/styled_overlay_region.dart';
import 'home_bar.dart';
import 'home_drawer.dart';
import 'page_status.dart';
import 'sliver_thumbnails.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messenger = ScaffoldMessenger.of(context);
    final scrollController = useMemoized(() {
      return AutoScrollController(axis: Axis.vertical);
    });
    final pageState = ref.watch(pageStateProvider);
    final pageData = ref.watch(pageDataProvider);
    final isFocused = useState(true);

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
      final current = scrollController.position.pixels;
      final estimatedFloor = scrollController.position.maxScrollExtent - 300;
      pageState.whenOrNull(error: (error, stackTrace) {
        if (current >= estimatedFloor) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
          );
        }
      });
    });

    return Scaffold(
      drawer: const HomeDrawer(),
      drawerEdgeDragWidth:
          isFocused.value ? MediaQuery.of(context).size.width : 30,
      onDrawerChanged: (focusOnDrawer) {
        if (focusOnDrawer) {
          messenger.hideCurrentSnackBar();
        }
        isFocused.value = !focusOnDrawer;
      },
      body: StyledOverlayRegion(
        child: DoubleBack(
          condition: isFocused.value,
          waitForSecondBackPress: 2,
          onConditionFail: () {
            messenger.hideCurrentSnackBar();
          },
          onFirstBackPress: (context) {
            messenger.showSnackBar(const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ));
          },
          child: HomeBar(
            onFocusChanged: (focusOnSearching) {
              if (focusOnSearching) {
                messenger.removeCurrentSnackBar();
              }
              isFocused.value = !focusOnSearching;
            },
            body: Stack(
              alignment: Alignment.center,
              children: [
                FloatingSearchBarScrollNotifier(
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                            10,
                            MediaQuery.of(context).viewPadding.top + 72,
                            10,
                            10),
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
                            bottom: MediaQuery.of(context).padding.bottom * 1.8,
                          ),
                          sliver: const SliverToBoxAdapter(child: PageStatus()),
                        )
                    ],
                  ),
                ),
                if (pageData.posts.isEmpty) const PageStatus(),
                const _EdgeShadow(),
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
    return Positioned.fill(
      child: IgnorePointer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top * 1.8,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomLeft,
                    colors: [tint.withOpacity(0.8), tint.withOpacity(0)],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom * 1.8,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topLeft,
                    colors: [tint.withOpacity(0.5), tint.withOpacity(0)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
