import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../../provider/common.dart';
import '../hooks/floating_searchbar_controller.dart';
import 'search_suggestions.dart';

class HomeBar extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useFloatingSearchBarController();
    final gridHandler = useProvider(gridProvider.notifier);
    final api = useProvider(apiProvider);
    final searchTag = useProvider(searchTagProvider);
    final searchTagHandler = useProvider(searchTagProvider.notifier);
    final searchHistory = useProvider(searchHistoryProvider);
    final suggestion = useState(<String>[]);
    final suggestionHistory = useState({});

    useEffect(() {
      // Populate suggestion history on first build
      searchHistory.mapped.then((it) {
        if (it.isNotEmpty) suggestionHistory.value = it;
      });
    }, [suggestionHistory]);

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
        searchHistory.push(query);
      },
      onQueryChanged: (value) async {
        suggestion.value = await api.fetchSuggestion(query: value);
        suggestionHistory.value =
            await searchHistory.composeSuggestion(query: value);
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
          suggestions: suggestion.value,
          history: suggestionHistory.value,
          onRemoveHistory: (key) async {
            searchHistory.delete(key);
            // rebuild history suggestion
            suggestionHistory.value =
                await searchHistory.composeSuggestion(query: controller.query);
          },
        );
      },
    );
  }
}
