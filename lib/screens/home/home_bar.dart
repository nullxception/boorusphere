import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../../../hooks/floating_searchbar_controller.dart';
import '../../entity/page_option.dart';
import '../../settings/active_server.dart';
import '../../settings/grid.dart';
import '../../source/page.dart';
import '../../utils/extensions/buildcontext.dart';
import 'search_suggestions.dart';

class HomeBar extends HookConsumerWidget {
  const HomeBar({super.key, this.body, this.onFocusChanged});

  final Widget? body;
  final Function(bool focused)? onFocusChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useFloatingSearchBarController();
    final grid = ref.watch(gridProvider);
    final pageOption = ref.watch(pageOptionProvider);
    final serverActive = ref.watch(activeServerProvider);

    useEffect(() {
      // Populate search tag on first build
      controller.query = pageOption.query;
    }, [controller]);

    return FloatingSearchBar(
      backgroundColor: context.theme.cardColor,
      elevation: 2,
      implicitDuration: Duration.zero,
      autocorrect: false,
      margins: EdgeInsets.fromLTRB(
          10.5, MediaQuery.of(context).viewPadding.top + 12, 10, 0),
      padding: EdgeInsets.zero,
      scrollPadding: EdgeInsets.zero,
      insets: EdgeInsets.zero,
      automaticallyImplyDrawerHamburger: false,
      automaticallyImplyBackButton: false,
      leadingActions: [
        SearchBarLeadingButton(searchBarController: controller),
      ],
      borderRadius: BorderRadius.circular(8),
      hint: 'Search on ${serverActive.name}...',
      controller: controller,
      debounceDelay: const Duration(milliseconds: 250),
      transitionCurve: Curves.easeInCirc,
      transition: ExpandingFloatingSearchBarTransition(),
      transitionDuration: const Duration(milliseconds: 250),
      onSubmitted: (value) {
        final query = value.trim();
        // restore title when user cancels search by submitting a blank input
        if (query.isEmpty && controller.query.trim() != pageOption.query) {
          controller.query = '${pageOption.query} ';
          return;
        }

        ref
            .read(pageOptionProvider.notifier)
            .update((state) => PageOption(query: query, clear: true));
        controller.close();
      },
      onFocusChanged: (focused) {
        onFocusChanged?.call(focused);
      },
      clearQueryOnClose: false,
      actions: [
        if (controller.isClosed)
          IconButton(
            icon: Icon(
              Icons.grid_view,
              size: (IconTheme.of(context).size ?? 24) + 4 - (4 * (grid + 1)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            onPressed: ref.read(gridProvider.notifier).rotate,
          ),
        if (controller.isOpen)
          IconButton(
            icon: const Icon(Icons.rotate_left),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            onPressed: () {
              if (controller.query.trim() != pageOption.query) {
                controller.query = '${pageOption.query} ';
              }
            },
          ),
        if (controller.isOpen)
          IconButton(
            icon: const Icon(Icons.close_rounded),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            onPressed: () {
              if (controller.query.isEmpty) {
                controller.query = pageOption.query;
                controller.close();
              } else {
                controller.clear();
              }
            },
          ),
      ],
      builder: (context, transition) {
        return SearchSuggestionView(controller: controller);
      },
      body: body,
    );
  }
}

class SearchBarLeadingButton extends HookWidget {
  const SearchBarLeadingButton({
    super.key,
    required this.searchBarController,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 8),
  });

  final FloatingSearchBarController searchBarController;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final animController =
        useAnimationController(duration: const Duration(milliseconds: 300));
    searchBarController.isOpen
        ? animController.reverse()
        : animController.forward();
    return IconButton(
      icon: AnimatedIcon(
        progress: animController,
        icon: AnimatedIcons.arrow_menu,
      ),
      padding: padding,
      onPressed: () {
        if (searchBarController.isOpen) {
          searchBarController.close();
        } else {
          Scaffold.of(context).openDrawer();
        }
      },
    );
  }
}
