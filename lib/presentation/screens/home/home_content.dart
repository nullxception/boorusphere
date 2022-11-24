import 'package:boorusphere/presentation/provider/booru/entity/fetch_result.dart';
import 'package:boorusphere/presentation/provider/booru/page_state.dart';
import 'package:boorusphere/presentation/screens/home/home_status.dart';
import 'package:boorusphere/presentation/screens/home/search/search_screen.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/widgets/timeline/timeline.dart';
import 'package:boorusphere/presentation/widgets/timeline/timeline_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeContent extends HookConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(pageStateProvider);
    final controller = useMemoized(
      () => TimelineController(
        onLoadMore: () => ref.read(pageStateProvider.notifier).loadMore(),
      ),
      [pageState.data.posts.hashCode],
    );
    final scrollController = controller.scrollController;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients ||
          pageState is DataFetchResult ||
          pageState is LoadingFetchResult) return;

      if (scrollController.position.extentAfter < 300) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastOutSlowIn,
        );
      }
    });

    final isNewSearch =
        pageState is! DataFetchResult && pageState.data.option.clear;

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
                  sliver: Timeline(
                    controller: controller,
                    posts: pageState.data.posts,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: context.mediaQuery.viewPadding.bottom * 1.8 + 92,
                ),
                sliver: const SliverToBoxAdapter(child: HomeStatus()),
              ),
            ],
          )
        else
          const HomeStatus(),
        const _EdgeShadow(),
        SearchScreen(scrollController: scrollController),
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
