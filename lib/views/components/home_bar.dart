import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../../provider/common.dart';
import '../hooks/floating_searchbar_controller.dart';

final _suggestionState = StateProvider<List<String>>((_) => []);

class HomeBar extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useFloatingSearchBarController();
    final gridHandler = useProvider(gridProvider.notifier);
    final api = useProvider(apiProvider);
    final searchTag = useProvider(searchTagProvider);
    final searchTagHandler = useProvider(searchTagProvider.notifier);
    final suggestion = useProvider(_suggestionState);

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
        return _SearchResult(controller: controller);
      },
    );
  }
}

class _SearchResult extends HookWidget {
  const _SearchResult({Key? key, required this.controller}) : super(key: key);

  final FloatingSearchBarController controller;

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
              return Column(
                children: [
                  ListTile(
                    horizontalTitleGap: 1,
                    leading: const Icon(Icons.tag, size: 24),
                    title: Text(suggestion.state[index]),
                    onTap: () {
                      controller.query = _concatSuggestionResult(
                        input: controller.query,
                        suggested: suggestion.state[index],
                      );
                    },
                  ),
                  if (index < suggestion.state.length - 1)
                    const Divider(height: 1),
                ],
              );
            },
            itemCount: suggestion.state.length,
          )),
    );
  }
}
