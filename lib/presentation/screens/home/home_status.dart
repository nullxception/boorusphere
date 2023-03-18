import 'dart:async';

import 'package:boorusphere/data/repository/booru/entity/booru_error.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/booru/entity/page_data.dart';
import 'package:boorusphere/presentation/provider/booru/page_state.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/entity/booru_rating.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:boorusphere/presentation/screens/home/page_args.dart';
import 'package:boorusphere/presentation/utils/extensions/strings.dart';
import 'package:boorusphere/presentation/widgets/error_info.dart';
import 'package:boorusphere/presentation/widgets/notice_card.dart';
import 'package:dio/dio.dart';
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
          error: (data, error, stackTrace) {
            return _ErrorStatus(
              data: data,
              error: error,
              stackTrace: stackTrace,
            );
          },
        ),
      ],
    );
  }
}

class _ErrorStatus extends ConsumerWidget {
  const _ErrorStatus({
    required this.data,
    this.error,
    this.stackTrace,
  });

  final PageData data;
  final Object? error;
  final StackTrace? stackTrace;

  Object? buildError(BuildContext context, ServerData server) {
    final e = error;
    if (e is DioError && e.response?.statusCode != null) {
      return context.t.pageStatus
          .httpError(serverName: server.name)
          .withDioErrorCode(e);
    } else if (e == BooruError.empty) {
      return data.option.query.isEmpty
          ? context.t.pageStatus.noResult(n: data.posts.length)
          : context.t.pageStatus
              .noResultForQuery(n: data.posts.length, query: data.option.query);
    } else if (e == BooruError.tagsBlocked) {
      return context.t.pageStatus.blocked(query: data.option.query);
    } else {
      return e;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageArgs = ref.watch(pageArgsProvider);
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
