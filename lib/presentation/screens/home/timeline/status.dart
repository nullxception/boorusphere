import 'dart:async';

import 'package:boorusphere/presentation/provider/booru/page_state_producer.dart';
import 'package:boorusphere/presentation/provider/settings/server/server_settings.dart';
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
    final safeMode = ref.watch(ServerSettingsProvider.safeMode);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        pageState.when(
          error: (data, err, trace) => Center(
            child: NoticeCard(
              icon: const Icon(Icons.search),
              margin: const EdgeInsets.all(16),
              children: Column(
                children: [
                  ExceptionInfo(
                    err: err,
                    stackTrace: trace,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (safeMode)
                        ElevatedButton(
                          onPressed: () async {
                            await ref
                                .watch(ServerSettingsProvider.safeMode.notifier)
                                .update(false);
                            unawaited(
                                ref.read(pageStateProvider.notifier).load());
                          },
                          style: ElevatedButton.styleFrom(elevation: 0),
                          child: const Text('Disable safe mode'),
                        ),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(pageStateProvider.notifier).load(),
                        style: ElevatedButton.styleFrom(elevation: 0),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          loading: (data) => Container(
            height: 50,
            alignment: Alignment.topCenter,
            child: SpinKitFoldingCube(
              size: 24,
              color: context.colorScheme.primary,
              duration: const Duration(seconds: 1),
            ),
          ),
          data: (data) => Container(
            height: 50,
            alignment: Alignment.topCenter,
            child: ElevatedButton(
              onPressed: () => ref.read(pageStateProvider.notifier).loadMore(),
              child: const Text('Load more'),
            ),
          ),
        ),
      ],
    );
  }
}
