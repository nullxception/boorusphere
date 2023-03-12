import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/favorite_post_state.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:boorusphere/presentation/screens/home/page_args.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/widgets/favicon.dart';
import 'package:boorusphere/presentation/widgets/notice_card.dart';
import 'package:boorusphere/presentation/widgets/timeline/timeline.dart';
import 'package:boorusphere/presentation/widgets/timeline/timeline_controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final favoritesPageArgsProvider =
    Provider.autoDispose<PageArgs>((ref) => throw UnimplementedError());

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key, this.args});
  final PageArgs? args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritePostState = ref.watch(favoritePostStateProvider);
    final savedServer =
        ref.read(serverSettingStateProvider.select((it) => it.active));
    final pageArgs = args ?? PageArgs(serverId: savedServer.id);
    return ProviderScope(
      overrides: [favoritesPageArgsProvider.overrideWith((ref) => pageArgs)],
      child: favoritePostState.isNotEmpty
          ? _Pager(favoritePostState)
          : _EmptyView(),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.favorites.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: NoticeCard(
                icon: const Icon(Icons.favorite),
                margin: const EdgeInsets.only(top: 64),
                children: Text(context.t.favorites.placeholder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pager extends ConsumerWidget {
  const _Pager(this.posts);

  final Iterable<Post> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverDataState = ref.watch(serverDataStateProvider);
    final pageArgs = ref.watch(favoritesPageArgsProvider);

    final pages = posts
        .groupListsBy(
          (e) => serverDataState.getById(e.serverId, or: ServerData.empty),
        )
        .entries
        .where((it) => it.key != ServerData.empty)
        .sortedBy((it) => it.key.id);

    return DefaultTabController(
      length: pages.length,
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: Text(context.t.favorites.title),
        ),
        body: TabBarView(
          children: [
            for (final page in pages)
              ProviderScope(
                overrides: [
                  timelineControllerProvider.overrideWith(
                    (ref) => TimelineController(pageArgs: pageArgs),
                  ),
                ],
                child: _Content(server: page.key, posts: page.value),
              ),
          ],
        ),
        bottomNavigationBar: Material(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
          ),
          color: context.theme.appBarTheme.backgroundColor,
          surfaceTintColor: context.colorScheme.surfaceTint,
          elevation: 3,
          child: SafeArea(
            child: TabBar(
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontSize: 12),
              padding: const EdgeInsets.all(8),
              isScrollable: true,
              labelPadding: const EdgeInsets.only(left: 8, right: 8),
              tabs: [
                for (final page in pages)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Tab(
                      text: page.key.name,
                      icon: Favicon(
                        url: page.key.homepage,
                        size: 24,
                        shape: BoxShape.rectangle,
                      ),
                    ),
                  ),
              ],
              indicator: BoxDecoration(
                color: context.colorScheme.background,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.posts, required this.server});

  final Iterable<Post> posts;
  final ServerData server;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineController = ref.watch(timelineControllerProvider);

    return CustomScrollView(
      controller: timelineController.scrollController,
      slivers: [
        SliverSafeArea(
          sliver: SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: Timeline(posts: posts),
          ),
        ),
      ],
    );
  }
}
