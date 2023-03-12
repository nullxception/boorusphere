import 'dart:async';

import 'package:boorusphere/data/repository/booru/entity/booru_error.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/booru/entity/page_data.dart';
import 'package:boorusphere/presentation/provider/booru/page_state.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/entity/booru_rating.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:boorusphere/presentation/screens/home/home_page.dart';
import 'package:boorusphere/presentation/utils/extensions/strings.dart';
import 'package:boorusphere/presentation/widgets/error_info.dart';
import 'package:boorusphere/presentation/widgets/notice_card.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeStatus extends HookConsumerWidget {
  const HomeStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(pageStateProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        pageState.when(
          idle: (data) {
            return const SizedBox.shrink();
          },
          data: (data) {
            return Container(
              height: 50,
              alignment: Alignment.topCenter,
              child: ElevatedButton(
                onPressed: ref.read(pageStateProvider.notifier).loadMore,
                child: Text(context.t.loadMore),
              ),
            );
          },
          loading: (data) {
            return Container(
              height: 50,
              alignment: Alignment.topCenter,
              child: const RefreshProgressIndicator(),
            );
          },
          error: (data, error, stackTrace, code) {
            return _ErrorStatus(
              data: data,
              error: error,
              stackTrace: stackTrace,
              code: code,
            );
          },
        ),
      ],
    );
  }
}

class _ErrorStatus extends ConsumerWidget {
  const _ErrorStatus({
    required this.code,
    required this.data,
    this.error,
    this.stackTrace,
  });

  final int code;
  final PageData data;
  final Object? error;
  final StackTrace? stackTrace;

  Object? buildError(BuildContext context, ServerData server) {
    final t = context.t;
    final q = data.option.query;
    final size = data.posts.length;
    switch (error) {
      case BooruError.httpError:
        return t.pageStatus
            .httpError(serverName: server.name)
            .withHttpErrCode(code);
      case BooruError.empty:
        return q.isEmpty
            ? t.pageStatus.noResult(n: size)
            : t.pageStatus.noResultForQuery(n: size, query: q);
      case BooruError.tagsBlocked:
        return t.pageStatus.blocked(query: q);
      default:
        return error;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageArgs = ref.watch(homePageArgsProvider);
    final server =
        ref.watch(serverDataStateProvider).getById(pageArgs.serverId);

    return Center(
      child: NoticeCard(
        icon: const Icon(Icons.search),
        margin: const EdgeInsets.all(16),
        children: Column(
          children: [
            ErrorInfo(
              error: buildError(context, server),
              stackTrace: stackTrace,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (data.option.searchRating == BooruRating.safe)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(elevation: 0),
                    onPressed: () async {
                      await ref
                          .read(serverSettingStateProvider.notifier)
                          .setRating(BooruRating.all);
                      if (context.mounted) {
                        unawaited(ref.read(pageStateProvider.notifier).load());
                      }
                    },
                    child: Text(context.t.rating.disableRatingSafe),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(elevation: 0),
                  onPressed: ref.read(pageStateProvider.notifier).load,
                  child: Text(context.t.retry),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
