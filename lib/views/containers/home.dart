import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../provider/booru_api.dart';
import '../components/home_bar.dart';
import '../components/home_drawer.dart';
import '../components/sliver_page_state.dart';
import '../components/sliver_thumbnails.dart';

final homeDrawerSwipeableProvider = StateProvider((_) => true);

class Home extends HookConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useMemoized(() {
      return AutoScrollController(axis: Axis.vertical);
    });
    final api = ref.watch(booruApiProvider);
    final pageLoading = ref.watch(pageLoadingProvider);
    final errorMessage = ref.watch(pageErrorProvider);
    final homeDrawerSwipeable = ref.watch(homeDrawerSwipeableProvider);
    final loadMoreCall = useCallback(() {
      if (errorMessage.isEmpty && !pageLoading) {
        // Infinite page with scroll detection
        final threshold = MediaQuery.of(context).size.height / 6;
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - threshold) {
          api.loadMore();
        }
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
      body: DoubleBack(
        onFirstBackPress: (context) {
          ScaffoldMessenger.of(context).showSnackBar(
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
                      padding: EdgeInsets.fromLTRB(10,
                          MediaQuery.of(context).viewPadding.top + 72, 10, 10),
                      sliver: SliverThumbnails(
                        autoScrollController: scrollController,
                      ),
                    ),
                    const SliverPageState()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
