import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../../model/search_history.dart';
import '../../provider/common.dart';
import '../hooks/floating_searchbar_controller.dart';

final _suggestionState = StateProvider<List<String>>((_) => []);
final _searchHistoryProvider =
    StateProvider((_) => Hive.box<SearchHistory>('searchHistory'));

class HomeBar extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useFloatingSearchBarController();
    final gridHandler = useProvider(gridProvider.notifier);
    final api = useProvider(apiProvider);
    final searchTag = useProvider(searchTagProvider);
    final searchTagHandler = useProvider(searchTagProvider.notifier);
    final suggestion = useProvider(_suggestionState);
    final history = useProvider(_searchHistoryProvider);
    final activeServer = useProvider(activeServerProvider);

    return FloatingSearchBar(
      autocorrect: false,
      margins: EdgeInsets.fromLTRB(
          10.5, MediaQuery.of(context).viewPadding.top + 12, 10, 0),
      borderRadius: BorderRadius.circular(8),
      hint: 'Search...',
      controller: controller,
      debounceDelay: const Duration(milliseconds: 250),
      onSubmitted: (value) {
        searchTagHandler.setTag(query: value);
        api.fetch(clear: true);
        controller.close();
        history.state.add(SearchHistory(
          query: value,
          server: activeServer.name,
        ));
      },
      onQueryChanged: (value) async {
        suggestion.state = await api.fetchSuggestion(query: value);
      },
      clearQueryOnClose: false,
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.grid_view),
            onPressed: gridHandler.rotate,
          ),
        ),
        FloatingSearchBarAction.icon(
          icon: const Icon(Icons.rotate_left),
          onTap: () {
            if (controller.query != searchTag) {
              controller.query = '$searchTag ';
            }
          },
          showIfOpened: true,
          showIfClosed: false,
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return _SearchSuggestionResult(controller: controller);
      },
    );
  }
}

class _SearchSuggestionResult extends StatefulHookWidget {
  const _SearchSuggestionResult({Key? key, required this.controller})
      : super(key: key);

  final FloatingSearchBarController controller;

  @override
  _SearchSuggestionResultState createState() => _SearchSuggestionResultState();
}

class _SearchSuggestionResultState extends State<_SearchSuggestionResult> {
  String _concatSuggestionResult({
    required String input,
    required String suggested,
  }) {
    final queries = input.split(' ');
    final result = queries.sublist(0, queries.length - 1)..add(suggested);
    return '${result.join(' ')} '.replaceAll('  ', ' ').trimLeft();
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = useProvider(_suggestionState);
    final history = useProvider(_searchHistoryProvider);
    final dataLength = suggestion.state.isEmpty
        ? history.state.length
        : suggestion.state.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Card(
          elevation: 4.0,
          color: Theme.of(context).cardColor,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            padding: const EdgeInsets.all(0),
            itemBuilder: (context, index) {
              final query = suggestion.state.isEmpty
                  ? history.state.values.elementAt(index).query
                  : suggestion.state[index];
              return Column(
                children: [
                  ListTile(
                    horizontalTitleGap: 1,
                    leading: Icon(
                        suggestion.state.isEmpty ? Icons.history : Icons.tag,
                        size: 24),
                    trailing: suggestion.state.isEmpty
                        ? IconButton(
                            onPressed: () {
                              history.state.deleteAt(index);
                              setState(() {});
                            },
                            icon: const Icon(Icons.delete_forever),
                          )
                        : null,
                    title: Text(query),
                    onTap: () {
                      widget.controller.query = _concatSuggestionResult(
                        input: widget.controller.query,
                        suggested: query,
                      );
                    },
                  ),
                  if (index < dataLength - 1) const Divider(height: 1),
                ],
              );
            },
            itemCount: dataLength,
          )),
    );
  }
}
