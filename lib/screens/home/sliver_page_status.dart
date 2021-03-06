import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../source/page.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../widgets/exception_info.dart';
import '../../widgets/notice_card.dart';

class SliverPageStatus extends HookConsumerWidget {
  const SliverPageStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageData = ref.watch(pageDataProvider);
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
                        onPressed: pageData.fetch,
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
              height: 50,
              alignment: Alignment.topCenter,
              child: SpinKitFoldingCube(
                size: 24,
                color: context.colorScheme.primary,
                duration: const Duration(seconds: 1),
              ),
            ),
          if (pageError.isEmpty && !pageLoading && pageData.posts.isNotEmpty)
            Container(
              height: 50,
              alignment: Alignment.topCenter,
              child: ElevatedButton(
                  onPressed: pageData.loadMore, child: const Text('Load more')),
            )
        ],
      ),
    );
  }
}
