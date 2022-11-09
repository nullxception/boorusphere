import 'package:boorusphere/screens/home/search/search.dart';
import 'package:boorusphere/screens/home/timeline/controller.dart';
import 'package:boorusphere/screens/home/timeline/status.dart';
import 'package:boorusphere/screens/home/timeline/timeline.dart';
import 'package:boorusphere/source/page.dart';
import 'package:boorusphere/utils/extensions/asyncvalue.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeContent extends HookConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(pageDataProvider.select((it) => it.posts));
    final pageState = ref.watch(pageStateProvider);
    final pageOption = ref.watch(pageOptionProvider);
    final controller = useTimelineController(
      posts: posts,
      onLoadMore: () => PageDataSource.loadMore(ref),
    );
    final scrollController = controller.scrollController;

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
                  sliver: Timeline(controller: controller),
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
