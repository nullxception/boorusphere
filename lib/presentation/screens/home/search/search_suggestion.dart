import 'package:boorusphere/data/repository/booru/entity/booru_error.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/booru/entity/fetch_result.dart';
import 'package:boorusphere/presentation/provider/booru/suggestion_state.dart';
import 'package:boorusphere/presentation/provider/search_history_state.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:boorusphere/presentation/screens/home/search/search_bar_controller.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/utils/extensions/strings.dart';
import 'package:boorusphere/presentation/widgets/blur_backdrop.dart';
import 'package:boorusphere/presentation/widgets/error_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchSuggestion extends HookConsumerWidget {
  const SearchSuggestion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchBar = ref.watch(searchBarController);
    final server = ref.watch(serverSettingStateProvider.select(
      (it) => it.active,
    ));
    final suggestion = ref.watch(suggestionStateProvider);
    final history = ref.watch(filterHistoryProvider(searchBar.value));
    final isBlurAllowed = ref.watch(uiSettingStateProvider.select(
      (ui) => ui.blur,
    ));

    useEffect(() {
      Future(() {
        if (searchBar.isOpen &&
            suggestion is! LoadingFetchResult &&
            suggestion.data.isEmpty) {
          ref.read(suggestionStateProvider.notifier).get(searchBar.value);
        }
      });
    }, [searchBar.isOpen]);

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
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  if (history.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(context.t.recently),
                            TextButton(
                              onPressed: ref
                                  .read(searchHistoryStateProvider.notifier)
                                  .clear,
                              child: Text(context.t.clear),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SliverList(
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
                              ref
                                  .read(searchHistoryStateProvider.notifier)
                                  .delete(entry.key);
                            },
                            background: Container(
                              color: Colors.red,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(context.t.remove),
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child:
                                        Icon(Icons.delete, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            child: _SuggestionEntryTile(
                              data: SuggestionEntry(
                                isHistory: true,
                                text: entry.value.query,
                                server: entry.value.server,
                              ),
                              onTap: searchBar.submit,
                              onAdded: searchBar.appendTyped,
                            ),
                          ),
                        );
                      },
                      childCount: history.entries.length,
                    ),
                  ),
                  if (!server.canSuggestTags)
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.search_off),
                          ),
                          Text(
                            context.t.suggestion.notSupported(
                              serverName: server.name,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (server.canSuggestTags)
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          context.t.suggestion.suggested(
                            serverName: server.name,
                          ),
                        ),
                      ),
                    ),
                  if (server.canSuggestTags)
                    suggestion.when(
                      data: (data) {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: _SuggestionEntryTile(
                                  data: SuggestionEntry(
                                    isHistory: false,
                                    text: data.elementAt(index),
                                  ),
                                  onTap: searchBar.submit,
                                  onAdded: searchBar.appendTyped,
                                ),
                              );
                            },
                            childCount: data.length,
                          ),
                        );
                      },
                      loading: (data) {
                        return SliverToBoxAdapter(
                          child: SizedBox(
                            height: 128,
                            child: Center(
                              child: SpinKitFoldingCube(
                                size: 24,
                                color: context.colorScheme.primary,
                                duration: const Duration(seconds: 1),
                              ),
                            ),
                          ),
                        );
                      },
                      error: (data, error, stackTrace, code) {
                        final Object? msg;
                        if (error == BooruError.empty) {
                          msg = context.t.suggestion
                              .empty(query: searchBar.value);
                        } else if (error == BooruError.httpError) {
                          msg = context.t.suggestion
                              .httpError(
                                query: searchBar.value,
                                serverName: server.name,
                              )
                              .withHttpErrCode(code);
                        } else {
                          msg = error;
                        }

                        return SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverToBoxAdapter(
                            child: ErrorInfo(error: msg),
                          ),
                        );
                      },
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: kBottomNavigationBarHeight + 16,
                    ),
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

class SuggestionEntry {
  SuggestionEntry({
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

  final SuggestionEntry data;
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
