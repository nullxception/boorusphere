import 'package:boorusphere/presentation/provider/booru/entity/fetch_state.dart';
import 'package:boorusphere/presentation/provider/booru/page_state.dart';
import 'package:boorusphere/presentation/screens/home/search/search.dart';
import 'package:boorusphere/presentation/screens/home/timeline/controller.dart';
import 'package:boorusphere/presentation/screens/home/timeline/status.dart';
import 'package:boorusphere/presentation/screens/home/timeline/timeline.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeContent extends HookConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(pageProvider);
    final controller = useTimelineController(
      onLoadMore: () => ref.read(pageProvider.notifier).loadMore(),
    );
    final scrollController = controller.scrollController;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients ||
          pageState is DataFetchState ||
          pageState is LoadingFetchState) return;

      if (scrollController.position.extentAfter < 300) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastOutSlowIn,
        );
      }
    });

    final isNewSearch =
        pageState is! DataFetchState && pageState.data.option.clear;

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
