part of 'search.dart';

class _SearchBar extends StatelessWidget {
  const _SearchBar({this.collapsed = false});

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8,
            sigmaY: 8,
            tileMode: TileMode.clamp,
          ),
          child: Container(
            color: context.theme.scaffoldBackgroundColor.withOpacity(
                context.brightness == Brightness.light ? 0.7 : 0.85),
            child: SafeArea(
              top: false,
              maintainBottomViewPadding: true,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(collapsed ? 0 : 0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                ),
                clipBehavior: Clip.hardEdge,
                margin: collapsed
                    ? const EdgeInsets.all(2)
                    : const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: collapsed ? const _CollapsedBar() : const _ExpandedBar(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static double innerHeight = kBottomNavigationBarHeight + 12;
}

class _ExpandedBar extends ConsumerWidget {
  const _ExpandedBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchBar = ref.watch(searchBarController);
    final grid = ref.watch(gridProvider);
    return Row(
      children: [
        const _LeadingButton(),
        Expanded(
          child: TextField(
            autofocus: true,
            controller: searchBar._textController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: searchBar.hint,
            ),
            textAlign: searchBar.isOpen ? TextAlign.start : TextAlign.center,
            readOnly: !searchBar.isOpen,
            onSubmitted: searchBar.submit,
            onTap: searchBar.isOpen ? null : searchBar.open,
            style: DefaultTextStyle.of(context).style,
          ),
        ),
        if (!searchBar.isOpen)
          IconButton(
            icon: Icon(
              Icons.grid_view,
              size: (IconTheme.of(context).size ?? 24) + 4 - (4 * (grid + 1)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            onPressed: ref.read(gridProvider.notifier).rotate,
          ),
        if (searchBar.isOpen)
          IconButton(
            icon: const Icon(Icons.rotate_left),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            onPressed: searchBar.reset,
          ),
        if (searchBar.isOpen)
          IconButton(
            icon: const Icon(Icons.close_rounded),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            onPressed: () {
              if (searchBar.text.isEmpty) {
                searchBar.reset();
                searchBar.close();
              } else {
                searchBar.clear();
              }
            },
          ),
      ],
    );
  }
}

class _CollapsedBar extends ConsumerWidget {
  const _CollapsedBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchBar = ref.watch(searchBarController);
    final serverActive = ref.watch(activeServerProvider);
    return InkWell(
      onTap: searchBar.open,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Favicon(
              url: '${serverActive.homepage}/favicon.ico',
              size: 14,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                searchBar.text.isEmpty
                    ? 'Search on ${serverActive.name}...'
                    : searchBar.text,
                style: context.theme.textTheme.bodySmall,
              ),
            ),
            const Icon(Icons.search, size: 14),
          ],
        ),
      ),
    );
  }
}

class _LeadingButton extends HookConsumerWidget {
  const _LeadingButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverActive = ref.watch(activeServerProvider);
    final searchBar = ref.watch(searchBarController);

    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animator) {
          final animation = Tween<double>(
            begin: 0,
            end: 1,
          ).animate(CurvedAnimation(
            parent: animator,
            curve: Curves.easeInOutCubic,
          ));
          return RotationTransition(
            turns: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
        child: searchBar.isOpen
            ? const Icon(Icons.arrow_back_rounded)
            : Favicon(url: '${serverActive.homepage}/favicon.ico', size: 21),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      onPressed: () {
        if (searchBar.isOpen) {
          searchBar.close();
        } else {
          Scaffold.of(context).openDrawer();
        }
      },
    );
  }
}
