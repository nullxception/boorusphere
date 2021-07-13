import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../../model/search_history.dart';
import '../../provider/common.dart';

class SearchSuggestionResult extends HookWidget {
  const SearchSuggestionResult({
    Key? key,
    required this.controller,
    required this.suggestions,
    required this.history,
    this.onRemoveHistory,
    this.onSearchTag,
  }) : super(key: key);

  final FloatingSearchBarController controller;
  final List<String> suggestions;
  final Map history;
  final Function(dynamic key)? onRemoveHistory;
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
  Widget build(BuildContext context) {
    final activeServer = useProvider(activeServerProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Visibility(
            visible: history.isNotEmpty,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text('Recently'),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            padding: const EdgeInsets.all(0),
            itemBuilder: (context, index) {
              final rIndex = history.length - 1 - index;
              return Column(
                children: [
                  Dismissible(
                    key: Key('item-of-$index'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      final key = history.keys.elementAt(rIndex);
                      onRemoveHistory?.call(key);
                    },
                    child: _SuggestionEntry(
                      query: history.values.elementAt(rIndex) as SearchHistory,
                      onTap: _searchTag,
                      onAdded: _addToInput,
                    ),
                    background: Container(
                      color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Remove'),
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                ],
              );
            },
            itemCount: history.length,
          ),
          if (suggestions.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(16, history.isEmpty ? 18 : 8, 16, 8),
              child: Text('Suggested at ${activeServer.name}'),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            padding: const EdgeInsets.all(0),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  _SuggestionEntry(
                    query: suggestions[index],
                    onTap: _searchTag,
                    onAdded: _addToInput,
                  ),
                  if (index < suggestions.length - 1) const Divider(height: 1),
                ],
              );
            },
            itemCount: suggestions.length,
          ),
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
