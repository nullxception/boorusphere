import 'package:boorusphere/data/source/page.dart';
import 'package:boorusphere/data/source/settings/safe_mode.dart';
import 'package:boorusphere/presentation/widgets/exception_info.dart';
import 'package:boorusphere/presentation/widgets/notice_card.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TimelineStatus extends ConsumerWidget {
  const TimelineStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(pageStateProvider);
    final safeMode = ref.watch(safeModeProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        pageState.maybeWhen(
          error: (error, stackTrace) => Center(
            child: NoticeCard(
              icon: const Icon(Icons.search),
              margin: const EdgeInsets.all(16),
              children: Column(
                children: [
                  ExceptionInfo(
                    err: error,
                    stackTrace: stackTrace,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (safeMode)
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .watch(safeModeProvider.notifier)
                                .update(false)
                                .then((_) => ref.refresh(pageStateProvider));
                          },
                          style: ElevatedButton.styleFrom(elevation: 0),
                          child: const Text('Disable safe mode'),
                        ),
                      ElevatedButton(
                        onPressed: () => ref.refresh(pageStateProvider),
                        style: ElevatedButton.styleFrom(elevation: 0),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
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
              onPressed: () => PageDataSource.loadMore(ref),
              child: const Text('Load more'),
            ),
          ),
        ),
      ],
    );
  }
}
