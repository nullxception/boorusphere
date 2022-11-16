import 'package:boorusphere/data/repository/booru/entity/booru_error.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/booru/suggestion_state.dart';
import 'package:boorusphere/presentation/provider/search_history.dart';
import 'package:boorusphere/presentation/provider/settings/server/server_settings.dart';
import 'package:boorusphere/presentation/provider/settings/ui/ui_settings.dart';
import 'package:boorusphere/presentation/screens/home/search/controller.dart';
import 'package:boorusphere/presentation/widgets/blur_backdrop.dart';
import 'package:boorusphere/presentation/widgets/error_info.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchSuggestion extends HookConsumerWidget {
  const SearchSuggestion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchBar = ref.watch(searchBarController);
    final serverActive = ref.watch(ServerSettingsProvider.active);
    final searchQuery = useState('');
    final suggestionState = ref.watch(suggestionProvider);
    final history = ref.watch(filteredHistoryProvider(searchQuery.value));
    final isBlurAllowed = ref.watch(UiSettingsProvider.blur);
    final updateQuery = useCallback(() {
      searchQuery.value = searchBar.text;
      ref.read(suggestionProvider.notifier).get(searchQuery.value);
    }, [searchBar]);

    useEffect(() {
      searchBar.addTextListener(updateQuery);
      return () {
        searchBar.removeTextListener(updateQuery);
      };
    }, [searchBar]);

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
                            Text(t.recently),
                            TextButton(
                              onPressed: ref
                                  .read(searchHistoryProvider.notifier)
                                  .clear,
                              child: Text(t.clear),
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
                                  .read(searchHistoryProvider.notifier)
                                  .delete(entry.key);
                            },
                            background: Container(
                              color: Colors.red,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(t.remove),
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
                              onAdded: searchBar.append,
                            ),
                          ),
                        );
                      },
                      childCount: history.entries.length,
                    ),
                  ),
                  if (!serverActive.canSuggestTags)
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.search_off),
                          ),
                          Text(
                            t.suggestion.notSupported(
                              serverName: serverActive.name,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (serverActive.canSuggestTags)
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          t.suggestion.suggested(
                            serverName: serverActive.name,
                          ),
                        ),
                      ),
                    ),
                  if (serverActive.canSuggestTags)
                    suggestionState.when(
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
                                  onAdded: searchBar.append,
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
                          msg = t.suggestion.empty(query: searchQuery.value);
                        } else if (error == BooruError.httpError) {
                          msg = t.suggestion.httpError(
                            n: code,
                            query: searchQuery.value,
                            serverName: serverActive.name,
                          );
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
          ? Text(t.suggestion.desc(serverName: data.server))
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
