import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../provider/page_manager.dart';
import 'notice_card.dart';

class SliverPageState extends HookConsumerWidget {
  const SliverPageState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageManager = ref.watch(pageManagerProvider);
    final pageLoading = ref.watch(pageLoadingProvider);
    final errorMessage = ref.watch(pageErrorProvider);

    return SliverToBoxAdapter(
      child: Column(
        children: [
          if (errorMessage.isNotEmpty)
            Center(
              child: NoticeCard(
                icon: const Icon(Icons.search),
                margin: const EdgeInsets.all(16),
                children: Column(
                  children: [
                    Text(errorMessage, textAlign: TextAlign.center),
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: ElevatedButton(
                        onPressed: pageManager.fetch,
                        style: ElevatedButton.styleFrom(elevation: 0),
                        child: const Text('Try again'),
                      ),
                    )
                  ],
                ),
              ),
            ),
          if (pageLoading)
            Container(
              height: 90,
              alignment: Alignment.center,
              child: SpinKitThreeBounce(
                  size: 32, color: Theme.of(context).colorScheme.primary),
            ),
          if (errorMessage.isEmpty &&
              !pageLoading &&
              pageManager.posts.isNotEmpty)
            Container(
              height: 90,
              alignment: Alignment.center,
              child: ElevatedButton(
                  onPressed: pageManager.loadMore,
                  child: const Text('Load more')),
            )
        ],
      ),
    );
  }
}
