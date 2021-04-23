import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../../model/search_history.dart';
import '../../provider/common.dart';
import '../hooks/floating_searchbar_controller.dart';
import 'search_suggestions.dart';

final _suggestionProvider = StateProvider<List<String>>((_) => []);
final _suggestionHistoryProvider = StateProvider<Map<dynamic, SearchHistory>>(
    (ref) => ref.read(searchHistoryBox).state.toMap());

class HomeBar extends HookWidget {
  Map<dynamic, SearchHistory> _buildSuggestionHistory({
    String query = '*',
    required Box<SearchHistory> history,
  }) {
    final mappedWithKeys = history.toMap();
    final queries = query.trim().split(' ');
    final last = queries.last.trim();

    // Filter the query, it must be longer than 2
    if (query.endsWith(' ') || last.length < 2) {
      return mappedWithKeys;
    }

    // Filtering history that contains last word from any state (either incomplete
    // or already contains multiple words)
    return mappedWithKeys
      ..removeWhere((key, value) =>
          !value.query.contains(last) ||
          queries.sublist(0, queries.length - 1).contains(value.query));
  }

  @override
  Widget build(BuildContext context) {
    final controller = useFloatingSearchBarController();
    final gridHandler = useProvider(gridProvider.notifier);
    final api = useProvider(apiProvider);
    final searchTag = useProvider(searchTagProvider);
    final searchTagHandler = useProvider(searchTagProvider.notifier);
    final suggestion = useProvider(_suggestionProvider);
    final history = useProvider(searchHistoryBox);
    final suggestionHistory = useProvider(_suggestionHistoryProvider);
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
        final query = value.trim();
        if (query.isEmpty) return;

        searchTagHandler.setTag(query: query);
        api.fetch(clear: true);
        controller.close();

        // Check if value already exist on the box
        final check = history.state.values.firstWhere(
          (it) => it.query == query,
          orElse: () => const SearchHistory(),
        );
        if (check.query != query) {
          history.state.add(SearchHistory(
            query: query,
            server: activeServer.name,
          ));
        }
      },
      onQueryChanged: (value) async {
        suggestion.state = await api.fetchSuggestion(query: value);
        suggestionHistory.state =
            _buildSuggestionHistory(query: value, history: history.state);
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
          history: suggestionHistory.state,
          onRemoveHistory: (key) {
            history.state.delete(key);
            // rebuild history suggestion
            suggestionHistory.state = _buildSuggestionHistory(
                query: controller.query, history: history.state);
          },
        );
      },
    );
  }
}
