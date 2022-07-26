import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../provider/page_manager.dart';
import '../../util/app_theme.dart';
import '../components/home_bar.dart';
import '../components/home_drawer.dart';
import '../components/sliver_page_state.dart';
import '../components/sliver_thumbnails.dart';

final homeDrawerSwipeableProvider = StateProvider((_) => true);

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messenger = ScaffoldMessenger.of(context);
    final scrollController = useMemoized(() {
      return AutoScrollController(axis: Axis.vertical);
    });
    final pageManager = ref.watch(pageManagerProvider);
    final pageLoading = ref.watch(pageLoadingProvider);
    final errorMessage = ref.watch(pageErrorProvider);
    final homeDrawerSwipeable = ref.watch(homeDrawerSwipeableProvider);
    final isDrawerOpened = useState(false);

    final loadMoreCall = useCallback(() {
      if (scrollController.position.extentAfter < 200) {
        pageManager.loadMore();
      }
    }, [key]);

    useEffect(() {
      scrollController.addListener(loadMoreCall);
      return () => scrollController.removeListener(loadMoreCall);
    }, [scrollController]);

    if (!pageLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final current = scrollController.position.pixels;
        final estimatedFloor = scrollController.position.maxScrollExtent - 200;
        if (errorMessage.isNotEmpty && current >= estimatedFloor) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
          );
        }
      });
    }

    return Scaffold(
      drawer: const HomeDrawer(),
      drawerEdgeDragWidth:
          homeDrawerSwipeable ? MediaQuery.of(context).size.width : 30,
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          messenger.hideCurrentSnackBar();
        }
        isDrawerOpened.value = isOpened;
      },
      body: AnnotatedRegion(
        value: AppTheme.systemUiOverlayStyleof(context).copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: DoubleBack(
          condition: !isDrawerOpened.value,
          onConditionFail: () {
            messenger.hideCurrentSnackBar();
          },
          onFirstBackPress: (context) {
            messenger.showSnackBar(
                const SnackBar(content: Text('Press back again to exit')));
          },
          child: HomeBar(
            body: Stack(
              fit: StackFit.expand,
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
                        ),
                      ),
                      const SliverPageState()
                    ],
                  ),
                ),
                _EdgeTopShadow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EdgeTopShadow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tint = Theme.of(context).scaffoldBackgroundColor;
    return Positioned(
      top: 0,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
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
    );
  }
}
