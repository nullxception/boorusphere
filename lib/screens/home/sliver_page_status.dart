import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/page.dart';
import '../../widgets/exception_info.dart';
import '../../widgets/notice_card.dart';

class SliverPageStatus extends HookConsumerWidget {
  const SliverPageStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageManager = ref.watch(pageManagerProvider);
    final pageLoading = ref.watch(pageLoadingProvider);
    final pageError = ref.watch(pageErrorProvider);

    return SliverToBoxAdapter(
      child: Column(
        children: [
          if (pageError.isNotEmpty)
            Center(
              child: NoticeCard(
                icon: const Icon(Icons.search),
                margin: const EdgeInsets.all(16),
                children: Column(
                  children: [
                    ExceptionInfo(
                      exception: pageError.first,
                      stackTrace: pageError.last,
                    ),
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
          if (pageError.isEmpty && !pageLoading && pageManager.posts.isNotEmpty)
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
