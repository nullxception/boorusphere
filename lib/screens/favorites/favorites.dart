import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../entity/post.dart';
import '../../entity/server_data.dart';
import '../../source/favorites.dart';
import '../../source/server.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../widgets/favicon.dart';
import '../../widgets/notice_card.dart';
import '../home/timeline/controller.dart';
import '../home/timeline/timeline.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasFav = ref.watch(favoritesProvider.select((it) => it.isNotEmpty));
    return hasFav ? _FavoritesView() : _EmptyView();
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

class _FavoritesView extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(favoritesProvider.select(
      (it) => it.values.groupListsBy((e) => ref
          .watch(serverDataProvider.notifier)
          .getByName(e.post.serverName, or: ServerData.empty)),
    ));

    final entries = grouped.entries
        .where((it) => it.key != ServerData.empty)
        .sortedBy((it) => it.key.name);
    final servers = entries.map((e) => e.key);
    final pages = entries.map(
      (e) => MapEntry(
        e.key,
        e.value.map((e) => e.post).toList(),
      ),
    );

    return DefaultTabController(
      length: servers.length,
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: const Text('Favorites'),
        ),
        body: TabBarView(
          children: [
            for (final page in pages)
              _Content(serverData: page.key, data: page.value),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: context.colorScheme.background.withOpacity(0.97),
          elevation: 0,
          child: TabBar(
            labelStyle: const TextStyle(fontSize: 12),
            padding: const EdgeInsets.all(8),
            isScrollable: true,
            tabs: [
              for (final server in servers) _Tab(serverData: server),
            ],
            indicator: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.serverData});

  final ServerData serverData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Favicon(
            url: '${serverData.homepage}/favicon.ico',
            size: 16,
            shape: BoxShape.circle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(serverData.name),
        ),
      ],
    );
  }
}

class _Content extends HookWidget {
  const _Content({required this.data, required this.serverData});

  final List<Post> data;
  final ServerData serverData;

  @override
  Widget build(BuildContext context) {
    final controller = useTimelineController(
      posts: data,
      heroKeyBuilder: (post) => 'fav@$serverData-${post.id}',
      keys: [data],
    );

    return CustomScrollView(
      controller: controller.scrollController,
      slivers: [
        SliverSafeArea(
          sliver: SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: Timeline(controller: controller),
          ),
        ),
      ],
    );
  }
}