import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../source/page.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../widgets/exception_info.dart';
import '../../widgets/notice_card.dart';

class PageStatus extends HookConsumerWidget {
  const PageStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageData = ref.watch(pageDataProvider);
    final pageState = ref.watch(pageStateProvider);

    return Column(
      children: [
        pageState.maybeWhen(
          error: (error, stackTrace) => Center(
            child: NoticeCard(
              icon: const Icon(Icons.search),
              margin: const EdgeInsets.all(16),
              children: Column(
                children: [
                  ExceptionInfo(
                    exception: error,
                    stackTrace: stackTrace,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: ElevatedButton(
                      onPressed: () => ref.refresh(pageStateProvider),
                      style: ElevatedButton.styleFrom(elevation: 0),
                      child: const Text('Try again'),
                    ),
                  )
                ],
              ),
            ),
          ),
          loading: () => Container(
            height: 50,
            alignment: Alignment.topCenter,
            child: SpinKitFoldingCube(
              size: 24,
              color: context.colorScheme.primary,
              duration: const Duration(seconds: 1),
            ),
          ),
          orElse: () => Container(
            height: 50,
            alignment: Alignment.topCenter,
            child: ElevatedButton(
                onPressed: pageData.loadMore, child: const Text('Load more')),
          ),
        ),
      ],
    );
  }
}
