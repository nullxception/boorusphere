import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../../entity/page_option.dart';
import '../../settings/active_server.dart';
import '../../source/page.dart';
import '../../source/search_history.dart';
import '../../source/suggestion.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../widgets/exception_info.dart';

class SearchSuggestionView extends HookConsumerWidget {
  const SearchSuggestionView({
    super.key,
    required this.controller,
  });

  final FloatingSearchBarController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeServer = ref.watch(activeServerProvider);
    final suggester = ref.watch(suggestionProvider(controller.query));
    final history = ref.watch(searchHistoryProvider);

    final addToInput = useCallback((String suggested) {
      final queries = controller.query.replaceAll('  ', ' ').split(' ');
      final result = queries.sublist(0, queries.length - 1).toSet()
        ..addAll(suggested.split(' '));

      controller.query = '${result.join(' ')} ';
    }, []);

    final searchTag = useCallback((String query) {
      controller.query = query;
      ref
          .read(pageOptionProvider.notifier)
          .update((state) => PageOption(query: query, clear: true));
      controller.close();
    }, []);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(searchHistoryProvider.notifier).rebuild(controller.query);
    });

    return CustomScrollView(
      slivers: [
        if (history.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recently'),
                  TextButton(
                    onPressed: ref.read(searchHistoryProvider.notifier).clear,
                    child: const Text('Clear all'),
                  ),
                ],
              ),
            ),
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final entry = history.entries.elementAt(index);
              return Dismissible(
                key: Key(entry.key.toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  ref.read(searchHistoryProvider.notifier)
                    ..delete(entry.key)
                    ..rebuild(controller.query.trim());
                },
                background: Container(
                  color: Colors.red,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text('Remove'),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(Icons.delete, color: Colors.white),
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
                  onTap: searchTag,
                  onAdded: addToInput,
                ),
              );
            },
            childCount: history.entries.length,
          ),
        ),
        if (!activeServer.canSuggestTags)
          SliverToBoxAdapter(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.search_off),
                ),
                Text('${activeServer.name} did not support search suggestion'),
              ],
            ),
          ),
        if (activeServer.canSuggestTags)
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
                child: Text('Suggested on ${activeServer.name}')),
          ),
        if (activeServer.canSuggestTags)
          suggester.when(
            data: (value) => SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return _SuggestionEntryTile(
                  data: SuggestionEntry(
                    isHistory: false,
                    text: value[index],
                    server: activeServer.name,
                  ),
                  onTap: searchTag,
                  onAdded: addToInput,
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
              sliver: SliverToBoxAdapter(child: ExceptionInfo(exception: ex)),
            ),
          )
      ],
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
