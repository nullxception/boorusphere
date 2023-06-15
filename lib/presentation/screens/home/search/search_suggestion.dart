import 'package:boorusphere/data/repository/booru/entity/booru_error.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/booru/entity/fetch_result.dart';
import 'package:boorusphere/presentation/provider/booru/suggestion_state.dart';
import 'package:boorusphere/presentation/provider/search_history_state.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:boorusphere/presentation/screens/home/search/search_bar_controller.dart';
import 'package:boorusphere/presentation/screens/home/search_session.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/utils/extensions/strings.dart';
import 'package:boorusphere/presentation/widgets/blur_backdrop.dart';
import 'package:boorusphere/presentation/widgets/error_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchSuggestion extends HookConsumerWidget {
  const SearchSuggestion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBlurAllowed =
        ref.watch(uiSettingStateProvider.select((ui) => ui.blur));

    return Container(
      color: context.theme.scaffoldBackgroundColor.withOpacity(
        context.isLightThemed
            ? isBlurAllowed
                ? 0.9
                : 0.95
            : isBlurAllowed
                ? 0.9
                : 0.98,
      ),
      child: BlurBackdrop(
        sigmaX: 12,
        sigmaY: 12,
        blur: isBlurAllowed,
        child: const Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  _SearchHistoryHeader(),
                  _SearchHistory(),
                  _SuggestionHeader(),
                  _Suggestion(),
                  SliverToBoxAdapter(
                    child: SizedBox(height: kBottomNavigationBarHeight + 38),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHistoryHeader extends ConsumerWidget {
  const _SearchHistoryHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchBar = ref.watch(searchBarControllerProvider);
    final history = ref.watch(filterHistoryProvider(searchBar.value));
    if (history.isEmpty) {
      return const SliverToBoxAdapter();
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${context.t.recently}: ${searchBar.value}'),
            TextButton(
              onPressed: ref.read(searchHistoryStateProvider.notifier).clear,
              child: Text(context.t.clear),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHistory extends HookConsumerWidget {
  const _SearchHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchBar = ref.watch(searchBarControllerProvider);
    final history = ref.watch(filterHistoryProvider(searchBar.value));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final reversed = history.entries.length - 1 - index;
          final entry = history.entries.elementAt(reversed);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Dismissible(
              key: Key(entry.key.toString()),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                ref.read(searchHistoryStateProvider.notifier).delete(entry.key);
              },
              background: Container(
                color: Colors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(context.t.remove),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ],
                ),
              ),
              child: _SuggestionEntryTile(
                data: _SuggestionEntry(
                  isHistory: true,
                  text: entry.value.query,
                  server: entry.value.server,
                ),
                onTap: (str) {
                  searchBar.submit(context, str);
                },
                onAdded: searchBar.appendTyped,
              ),
            ),
          );
        },
        childCount: history.entries.length,
      ),
    );
  }
}

class _SuggestionHeader extends ConsumerWidget {
  const _SuggestionHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(searchSessionProvider);
    final server = ref.watch(serverStateProvider).getById(session.serverId);

    if (!server.canSuggestTags) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.search_off),
            ),
            Text(context.t.suggestion.notSupported(serverName: server.name)),
          ],
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Text(context.t.suggestion.suggested(serverName: server.name)),
      ),
    );
  }
}

class _Suggestion extends HookConsumerWidget {
  const _Suggestion();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(searchSessionProvider);
    final server = ref.watch(serverStateProvider).getById(session.serverId);
    final searchBar = ref.watch(searchBarControllerProvider);
    final suggestion = ref.watch(suggestionStateProvider);

    useEffect(() {
      Future(() {
        if (searchBar.isOpen && suggestion is! LoadingFetchResult) {
          ref.watch(suggestionStateProvider.notifier).get(searchBar.value);
        }
      });
    }, [searchBar.isOpen]);

    if (!server.canSuggestTags) {
      return const SliverToBoxAdapter();
    }

    return switch (suggestion) {
      IdleFetchResult() => const SliverToBoxAdapter(
          child: SizedBox.shrink(),
        ),
      DataFetchResult(:final data) => SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _SuggestionEntryTile(
                  data: _SuggestionEntry(
                    isHistory: false,
                    text: data.elementAt(index),
                  ),
                  onTap: (str) {
                    searchBar.submit(context, str);
                  },
                  onAdded: searchBar.appendTyped,
                ),
              );
            },
            childCount: data.length,
          ),
        ),
      LoadingFetchResult() => const SliverToBoxAdapter(
          child: SizedBox(
            height: 128,
            child: Center(child: RefreshProgressIndicator()),
          ),
        ),
      ErrorFetchResult(:final error) => _ErrorSuggestion(
          error: error,
          query: searchBar.value,
          serverName: server.name,
        ),
    };
  }
}

class _ErrorSuggestion extends StatelessWidget {
  const _ErrorSuggestion({
    required this.query,
    required this.serverName,
    required this.error,
  });

  final String query;
  final String serverName;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final err = error;
    Object? msg;

    if (err == BooruError.empty) {
      msg = context.t.suggestion.empty(query: query);
    } else if (err is DioException && err.response?.statusCode != null) {
      msg = context.t.suggestion
          .httpError(query: query, serverName: serverName)
          .withDioExceptionCode(err);
    } else {
      msg = err;
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: ErrorInfo(error: msg),
      ),
    );
  }
}

class _SuggestionEntry {
  _SuggestionEntry({
    this.text = '',
    this.server = '',
    required this.isHistory,
  });

  final String text;
  final String server;
  final bool isHistory;
}

class _SuggestionEntryTile extends StatelessWidget {
  const _SuggestionEntryTile({
    required this.data,
    required this.onTap,
    required this.onAdded,
  });

  final _SuggestionEntry data;
  final Function(String entry) onTap;
  final Function(String entry) onAdded;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      horizontalTitleGap: 1,
      leading: Icon(data.isHistory ? Icons.history : Icons.tag, size: 22),
      title: Text(data.text),
      subtitle: data.server.isNotEmpty
          ? Text(context.t.suggestion.desc(serverName: data.server))
          : null,
      onTap: () => onTap.call(data.text),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => onAdded.call(data.text),
            icon: const Icon(Icons.add, size: 22),
          ),
        ],
      ),
    );
  }
}
