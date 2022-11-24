import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/favorite_post_state.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/widgets/favicon.dart';
import 'package:boorusphere/presentation/widgets/notice_card.dart';
import 'package:boorusphere/presentation/widgets/timeline/timeline.dart';
import 'package:boorusphere/presentation/widgets/timeline/timeline_controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritePostState = ref.watch(favoritePostStateProvider);
    return favoritePostState.isNotEmpty
        ? _Pager(favoritePostState)
        : _EmptyView();
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

class _Pager extends HookConsumerWidget {
  const _Pager(this.posts);

  final Iterable<Post> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverDataState = ref.watch(serverDataStateProvider);

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
              _Content(server: page.key, posts: page.value),
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
              for (final page in pages) _Tab(server: page.key),
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
  const _Tab({required this.server});

  final ServerData server;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Favicon(
            url: server.homepage,
            size: 16,
            shape: BoxShape.circle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(server.name),
        ),
      ],
    );
  }
}

class _Content extends HookWidget {
  const _Content({required this.posts, required this.server});

  final Iterable<Post> posts;
  final ServerData server;

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(
      TimelineController.new,
      [posts.hashCode],
    );
    return CustomScrollView(
      controller: controller.scrollController,
      slivers: [
        SliverSafeArea(
          sliver: SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: Timeline(controller: controller, posts: posts),
          ),
        ),
      ],
    );
  }
}
