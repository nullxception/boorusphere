import 'dart:async';

import 'package:boorusphere/presentation/provider/booru/entity/fetch_result.dart';
import 'package:boorusphere/presentation/provider/booru/page_state.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/tags_blocker_state.dart';
import 'package:boorusphere/presentation/screens/home/home_status.dart';
import 'package:boorusphere/presentation/screens/home/search/search_screen.dart';
import 'package:boorusphere/presentation/screens/home/search_session.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
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
    final session = ref.watch(searchSessionProvider);
    final servers = ref.watch(serverStateProvider);
    final blockedTags = ref.watch(tagsBlockerStateProvider.select(
      (state) => state.values
          .where((it) => it.serverId.isEmpty || it.serverId == session.serverId)
          .map((it) => it.name),
    ));

    final filteredPosts = pageState.data.posts
        .where((it) => !it.allTags.any(blockedTags.contains));

    useEffect(() {
      if (servers.isNotEmpty) {
        Future(() {
          ref.read(pageStateProvider.notifier).update(
              (option) => option.copyWith(query: session.query, clear: true));
        });
      }
    }, [servers.isNotEmpty]);

    final timelineController = ref.watch(timelineControllerProvider);
    final scrollController = timelineController.scrollController;

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
        RefreshIndicator(
          onRefresh: () async {
            unawaited(ref
                .read(pageStateProvider.notifier)
                .update((it) => it.copyWith(clear: true)));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            slivers: [
              if (!isNewSearch)
                SliverSafeArea(
                  sliver: SliverPadding(
                    padding: const EdgeInsets.all(10),
                    sliver: Timeline(
                      posts: filteredPosts,
                    ),
                  ),
                ),
              if (!isNewSearch)
                SliverPadding(
                  padding: EdgeInsets.only(
                    bottom: context.mediaQuery.viewPadding.bottom * 1.8 + 92,
                  ),
                  sliver: const SliverToBoxAdapter(child: HomeStatus()),
                )
              else
                const SliverFillRemaining(child: HomeStatus()),
            ],
          ),
        ),
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
