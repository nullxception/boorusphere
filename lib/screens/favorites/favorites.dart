import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

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
    final serverNames = ref.watch(favoritesProvider.select(
      (it) => it.values.map((e) => e.post.serverName).toSet(),
    ));

    return DefaultTabController(
      length: serverNames.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final serverName in serverNames)
                _FavoriteTab(serverName: serverName),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final serverName in serverNames)
              _FavoriteTimeline(serverName: serverName),
          ],
        ),
      ),
    );
  }
}

class _FavoriteTab extends ConsumerWidget {
  const _FavoriteTab({required this.serverName});

  final String serverName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref.watch(serverDataProvider.notifier).select(serverName);

    return Row(
      children: [
        Favicon(
          url: '${server.homepage}/favicon.ico',
          size: 12,
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(server.name),
        ),
      ],
    );
  }
}

class _FavoriteTimeline extends HookConsumerWidget {
  const _FavoriteTimeline({required this.serverName});

  final String serverName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useMemoized(() {
      return AutoScrollController(axis: Axis.vertical);
    });

    final posts = ref.watch(favoritesProvider.select(
      (value) => value.values
          .where((it) => it.post.serverName == serverName)
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
