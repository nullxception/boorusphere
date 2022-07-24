import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../../model/server_data.dart';
import '../../provider/page_manager.dart';
import '../../provider/query.dart';
import '../../provider/search_history_manager.dart';
import '../../provider/settings/active_server.dart';
import '../../provider/settings/grid.dart';
import '../containers/home.dart';
import '../hooks/floating_searchbar_controller.dart';
import 'search_suggestions.dart';

class HomeBar extends HookConsumerWidget {
  const HomeBar({super.key, this.body});

  final Widget? body;

  void _searchForTag({
    required String value,
    required FloatingSearchBarController controller,
    required QueryState searchTagHandler,
    required PageManager pageManager,
    required String searchTag,
  }) {
    final query = value.trim();

    // restore title when user cancels search by submitting a blank input
    if (query.isEmpty) {
      if (controller.query != searchTag) {
        controller.query = '$searchTag ';
      }
      return;
    }

    searchTagHandler.setTag(query: query);
    pageManager.posts.clear();
    pageManager.fetch();
    controller.close();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useFloatingSearchBarController();
    final gridHandler = ref.watch(gridProvider.notifier);
    final grid = ref.watch(gridProvider);
    final pageManager = ref.watch(pageManagerProvider);
    final query = ref.watch(queryProvider);
    final queryNotifier = ref.watch(queryProvider.notifier);
    final searchHistory = ref.watch(searchHistoryProvider);
    final homeDrawerSwipeable = ref.watch(homeDrawerSwipeableProvider.state);
    final activeServer = ref.watch(activeServerProvider);

    final suggestionHistory = useState({});
    final typedQuery = useState('');

    useEffect(() {
      // Populate search tag on first build
      controller.query = query.tags == ServerData.defaultTag ? '' : query.tags;
    }, [query]);

    useEffect(() {
      // Populate suggestion history on first build
      if (searchHistory.mapped.isNotEmpty) {
        suggestionHistory.value = searchHistory.mapped;
      }
    }, [suggestionHistory]);

    return FloatingSearchBar(
      backgroundColor: Theme.of(context).cardColor,
      elevation: 2,
      implicitDuration: Duration.zero,
      autocorrect: false,
      margins: EdgeInsets.fromLTRB(
          10.5, MediaQuery.of(context).viewPadding.top + 12, 10, 0),
      borderRadius: BorderRadius.circular(8),
      hint: 'Search...',
      controller: controller,
      debounceDelay: const Duration(milliseconds: 250),
      transitionCurve: Curves.easeInCirc,
      transition: ExpandingFloatingSearchBarTransition(),
      transitionDuration: const Duration(milliseconds: 250),
      onSubmitted: (value) {
        _searchForTag(
          value: value,
          pageManager: pageManager,
          controller: controller,
          searchTag: query.tags,
          searchTagHandler: queryNotifier,
        );
      },
      onQueryChanged: (value) async {
        if (activeServer.canSuggestTags) {
          typedQuery.value = value.trim();
        }
        suggestionHistory.value = searchHistory.composeSuggestion(query: value);
      },
      onFocusChanged: (focused) {
        homeDrawerSwipeable.state = !focused;
      },
      clearQueryOnClose: false,
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: Icon(
              Icons.grid_view,
              size: (IconTheme.of(context).size ?? 24) + 4 - (4 * (grid + 1)),
            ),
            onPressed: gridHandler.rotate,
          ),
        ),
        FloatingSearchBarAction.icon(
          icon: const Icon(Icons.rotate_left),
          onTap: () {
            if (controller.query != query.tags) {
              controller.query = '${query.tags} ';
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
            query: typedQuery.value,
            controller: controller,
            history: suggestionHistory.value,
            onClearHistory: () async {
              searchHistory.clear();
              suggestionHistory.value = {};
            },
            onRemoveHistory: (key) async {
              searchHistory.delete(key);
              // rebuild history suggestion
              suggestionHistory.value = searchHistory.composeSuggestion(
                query: controller.query.trim(),
              );
            },
            onSearchTag: (value) {
              _searchForTag(
                value: value,
                pageManager: pageManager,
                controller: controller,
                searchTag: query.tags,
                searchTagHandler: queryNotifier,
              );
            });
      },
      body: body,
    );
  }
}
