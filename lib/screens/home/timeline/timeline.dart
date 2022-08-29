import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../source/page.dart';
import '../../../utils/extensions/asyncvalue.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../search/search.dart';
import 'content.dart';
import 'status.dart';

class Timeline extends HookConsumerWidget {
  const Timeline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useMemoized(() {
      return AutoScrollController(axis: Axis.vertical);
    });
    final pageState = ref.watch(pageStateProvider);
    final pageOption = ref.watch(pageOptionProvider);
    final posts = ref.watch(pageDataProvider.select((it) => it.posts));

    final loadMoreCall = useCallback(() {
      if (!scrollController.hasClients) return;
      if (scrollController.position.extentAfter < 200) {
        PageDataSource.loadMore(ref);
      }
    }, [scrollController]);

    useEffect(() {
      scrollController.addListener(loadMoreCall);
      return () => scrollController.removeListener(loadMoreCall);
    }, [scrollController]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      if (pageState.isError && scrollController.position.extentAfter < 300) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastOutSlowIn,
        );
      }
    });

    final isNewSearch = !pageState.isData && pageOption.clear;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (!isNewSearch)
          CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverSafeArea(
                sliver: SliverPadding(
                  padding: const EdgeInsets.all(10),
                  sliver: TimelineContent(
                    scrollController: scrollController,
                    posts: posts,
                    onLoadMore: () {
                      PageDataSource.loadMore(ref);
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: context.mediaQuery.viewPadding.bottom * 1.8 + 92,
                ),
                sliver: const SliverToBoxAdapter(child: TimelineStatus()),
              ),
            ],
          )
        else
          const TimelineStatus(),
        const _EdgeShadow(),
        SearchableView(scrollController: scrollController),
      ],
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
                colors: [
                  tint.withOpacity(0.8),
                  tint.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
