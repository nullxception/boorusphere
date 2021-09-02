import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../provider/common.dart';
import '../components/home_bar.dart';
import '../components/home_drawer.dart';
import '../components/sliver_page_state.dart';
import '../components/sliver_thumbnails.dart';

class Home extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final scrollController = useMemoized(() {
      return AutoScrollController(axis: Axis.vertical);
    });
    final api = useProvider(apiProvider);
    final pageLoading = useProvider(pageLoadingProvider);
    final errorMessage = useProvider(errorMessageProvider);
    final homeDrawerSwipeable = useProvider(homeDrawerSwipeableProvider);

    useEffect(() {
      void loadMore() {
        if (errorMessage.state.isNotEmpty) return;

        // Infinite page with scroll detection
        final threshold = MediaQuery.of(context).size.height / 6;
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - threshold) {
          api.loadMore();
        }
      }

      scrollController.addListener(loadMore);
      return () => scrollController.removeListener(loadMore);
    }, [scrollController]);

    if (!pageLoading.state) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        final current = scrollController.position.pixels;
        final estimatedFloor = scrollController.position.maxScrollExtent - 200;
        if (errorMessage.state.isNotEmpty && current >= estimatedFloor) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
          );
        }
      });
    }

    return Scaffold(
      drawer: HomeDrawer(),
      drawerEdgeDragWidth:
          homeDrawerSwipeable.state ? MediaQuery.of(context).size.width : 30,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                    10, MediaQuery.of(context).viewPadding.top + 72, 10, 10),
                sliver: SliverThumbnails(
                  autoScrollController: scrollController,
                ),
              ),
              SliverPageState()
            ],
          ),
          HomeBar(),
        ],
      ),
    );
  }
}
