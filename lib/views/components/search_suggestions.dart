import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../../model/search_history.dart';
import '../../provider/booru_api.dart';
import '../../provider/server_data.dart';

class SearchSuggestionResult extends HookConsumerWidget {
  const SearchSuggestionResult({
    Key? key,
    required this.query,
    required this.controller,
    required this.history,
    this.onRemoveHistory,
    this.onClearHistory,
    this.onSearchTag,
  }) : super(key: key);

  final FloatingSearchBarController controller;
  final Map history;
  final String query;
  final Function(dynamic key)? onRemoveHistory;
  final Function()? onClearHistory;
  final Function(String value)? onSearchTag;

  void _addToInput(String suggested) {
    final queries = controller.query.split(' ');
    final result = queries.sublist(0, queries.length - 1)..add(suggested);
    controller.query = '${result.join(' ')} '.replaceAll('  ', ' ').trimLeft();
  }

  void _searchTag(String query) {
    controller.query = query;
    onSearchTag?.call(query);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref.watch(serverDataProvider);
    final suggester = ref.watch(suggestionProvider(query));
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Visibility(
            visible: history.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recently'),
                  TextButton(
                    onPressed: () {
                      onClearHistory?.call();
                    },
                    child: Text(
                      'Clear all',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            padding: const EdgeInsets.all(0),
            itemBuilder: (context, index) {
              final rIndex = history.length - 1 - index;
              final key = history.keys.elementAt(rIndex);
              return Column(
                children: [
                  Dismissible(
                    key: Key(key.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      onRemoveHistory?.call(key);
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
                    child: _SuggestionEntry(
                      query: history.values.elementAt(rIndex) as SearchHistory,
                      onTap: _searchTag,
                      onAdded: _addToInput,
                    ),
                  ),
                  const Divider(height: 1),
                ],
              );
            },
            itemCount: history.length,
          ),
          if (!server.active.canSuggestTags)
            Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.search_off),
                  ),
                  Text(
                      '${server.active.name} did not support search suggestion'),
                ],
              ),
            ),
          if (server.active.canSuggestTags)
            Padding(
              padding: EdgeInsets.fromLTRB(16, history.isEmpty ? 18 : 8, 16, 8),
              child: Text('Suggested at ${server.active.name}'),
            ),
          if (server.active.canSuggestTags)
            suggester.when(
              data: (value) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  padding: const EdgeInsets.all(0),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        _SuggestionEntry(
                          query: value[index],
                          onTap: _searchTag,
                          onAdded: _addToInput,
                        ),
                        if (index < value.length - 1) const Divider(height: 1),
                      ],
                    );
                  },
                  itemCount: value.length,
                );
              },
              loading: () => SizedBox(
                height: 128,
                child: Center(
                  child: SpinKitThreeBounce(
                      size: 32,
                      color: Theme.of(context).colorScheme.onBackground),
                ),
              ),
              error: (ex, _) => SizedBox(
                height: 128,
                child: Center(
                  child: Text(ex.toString().split(':')[1]),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class _SuggestionEntry extends StatelessWidget {
  const _SuggestionEntry({
    Key? key,
    required this.query,
    required this.onTap,
    required this.onAdded,
  }) : super(key: key);

  final dynamic query;
  final Function(String entry) onTap;
  final Function(String entry) onAdded;

  @override
  Widget build(BuildContext context) {
    final isHistory = query is SearchHistory;
    final tag = isHistory ? (query as SearchHistory).query : query as String;
    final serverName = isHistory ? (query as SearchHistory).server : '';

    return ListTile(
      horizontalTitleGap: 1,
      leading: Icon(isHistory ? Icons.history : Icons.tag, size: 22),
      title: Text(tag),
      subtitle: serverName.isNotEmpty ? Text('at $serverName') : null,
      onTap: () => onTap.call(tag),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => onAdded.call(tag),
            icon: const Icon(Icons.add, size: 22),
          ),
        ],
      ),
    );
  }
}
