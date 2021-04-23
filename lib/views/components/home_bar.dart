import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../../model/search_history.dart';
import '../../provider/common.dart';
import '../hooks/floating_searchbar_controller.dart';
import 'search_suggestions.dart';

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
        return SearchSuggestionResult(
          controller: controller,
          suggestions: suggestion.state,
          history: history.state.values,
          onRemoveHistory: (index) {
            history.state.deleteAt(index);
          },
        );
      },
    );
  }
}
