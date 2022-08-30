import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../entity/server_data.dart';
import '../../source/favorites.dart';
import '../../source/server.dart';
import '../../widgets/favicon.dart';
import '../../widgets/notice_card.dart';
import '../home/timeline/content.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasFav = ref.watch(favoritesProvider.select((it) => it.isNotEmpty));
    return hasFav ? _FavoritesView() : _EmptyView();
  }
}

class _FavoritesView extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(favoritesProvider.select(
      (it) => it.values
          .map((e) => ref
              .watch(serverDataProvider.notifier)
              .getByName(e.post.serverName, or: ServerData.empty))
          .where((e) => e != ServerData.empty)
          .toSet(),
    ));

    return DefaultTabController(
      length: servers.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final server in servers) _FavoriteTab(serverData: server),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final server in servers) _FavoriteTimeline(serverData: server),
          ],
        ),
      ),
    );
  }
}

class _FavoriteTab extends ConsumerWidget {
  const _FavoriteTab({required this.serverData});

  final ServerData serverData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Favicon(
          url: '${serverData.homepage}/favicon.ico',
          size: 12,
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(serverData.name),
        ),
      ],
    );
  }
}

class _FavoriteTimeline extends HookConsumerWidget {
  const _FavoriteTimeline({required this.serverData});

  final ServerData serverData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useMemoized(() {
      return AutoScrollController(axis: Axis.vertical);
    });

    final posts = ref.watch(favoritesProvider.select(
      (value) => value.values
          .where((it) => it.post.serverName == serverData.name)
          .map((it) => it.post),
    ));

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverSafeArea(
          sliver: SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: TimelineContent(
              scrollController: scrollController,
              posts: posts.toList(),
              heroPrefix: 'fav-${serverData.key}',
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: SafeArea(
        child: Column(
          children: const [
            Center(
              child: NoticeCard(
                icon: Icon(Icons.favorite),
                margin: EdgeInsets.only(top: 64),
                children: Text('Your saved content will appear here'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
