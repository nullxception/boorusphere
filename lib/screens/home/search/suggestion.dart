part of 'search.dart';

class _SearchSuggestion extends HookConsumerWidget {
  const _SearchSuggestion();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchBar = ref.watch(searchBarController);
    final serverActive = ref.watch(serverActiveProvider);
    final searchQuery = useState('');
    final suggester = ref.watch(suggestionFuture(searchQuery.value));
    final history = ref.watch(searchHistoryFinder(searchQuery.value));
    final isBlurAllowed = ref.watch(uiBlurProvider);
    final updateQuery = useCallback(() {
      searchQuery.value = searchBar.text;
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
                            const Text('Recently'),
                            TextButton(
                              onPressed: ref
                                  .read(searchHistoryProvider.notifier)
                                  .clear,
                              child: const Text('Clear all'),
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
                                children: const [
                                  Text('Remove'),
                                  Padding(
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
                              '${serverActive.name} did not support search suggestion'),
                        ],
                      ),
                    ),
                  if (serverActive.canSuggestTags)
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                          child: Text('Suggested on ${serverActive.name}')),
                    ),
                  if (serverActive.canSuggestTags)
                    suggester.when(
                      data: (value) => SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: _SuggestionEntryTile(
                              data: SuggestionEntry(
                                isHistory: false,
                                text: value.elementAt(index),
                              ),
                              onTap: searchBar.submit,
                              onAdded: searchBar.append,
                            ),
                          );
                        }, childCount: value.length),
                      ),
                      loading: () => SliverToBoxAdapter(
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
                      ),
                      error: (ex, trace) => SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver:
                            SliverToBoxAdapter(child: ExceptionInfo(err: ex)),
                      ),
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
      subtitle: data.server.isNotEmpty ? Text('at ${data.server}') : null,
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
