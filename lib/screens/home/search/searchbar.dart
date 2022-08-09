part of 'search.dart';

class _SearchBar extends ConsumerWidget {
  const _SearchBar({this.collapsed = false, this.scrollController});

  final bool collapsed;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchBar = ref.watch(searchBarController);
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
                    ? const EdgeInsets.fromLTRB(32, 4, 32, 0)
                    : const EdgeInsets.fromLTRB(16, 11, 16, 11),
                child: Row(
                  children: [
                    _LeadingButton(collapsed: collapsed),
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        controller: searchBar._textController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: searchBar.hint,
                          isDense: true,
                        ),
                        textAlign: searchBar.isOpen
                            ? TextAlign.start
                            : TextAlign.center,
                        readOnly: !searchBar.isOpen,
                        onSubmitted: searchBar.submit,
                        onTap: searchBar.isOpen ? null : searchBar.open,
                        style: DefaultTextStyle.of(context)
                            .style
                            .copyWith(fontSize: 13),
                      ),
                    ),
                    if (!searchBar.isOpen)
                      _TrailingButton(
                          collapsed: collapsed,
                          scrollController: scrollController),
                    if (searchBar.isOpen && searchBar.isTextChanged)
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static double innerHeight = kBottomNavigationBarHeight + 12;
}

class _CollapsibleButton extends StatelessWidget {
  const _CollapsibleButton({
    this.collapsed = false,
    required this.onTap,
    this.child,
  });

  final bool collapsed;
  final void Function() onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 300),
        padding: collapsed
            ? const EdgeInsets.fromLTRB(16, 6, 16, 6)
            : const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: collapsed ? 0.75 : 1,
          child: child,
        ),
      ),
    );
  }
}

class _LeadingButton extends HookConsumerWidget {
  const _LeadingButton({this.collapsed = false});

  final bool collapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverActive = ref.watch(activeServerProvider);
    final searchBar = ref.watch(searchBarController);

    return _CollapsibleButton(
      collapsed: collapsed,
      onTap: () {
        if (searchBar.isOpen) {
          searchBar.close();
        } else {
          Scaffold.of(context).openDrawer();
        }
      },
      child: AnimatedSwitcher(
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
    );
  }
}

class _TrailingButton extends ConsumerWidget {
  const _TrailingButton({this.collapsed = false, this.scrollController});

  final bool collapsed;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = IconTheme.of(context).size ?? 24;
    final grid = ref.watch(gridProvider);

    backToTop() {
      scrollController?.animateTo(0,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic);
    }

    return _CollapsibleButton(
      onTap: collapsed ? backToTop : ref.read(gridProvider.notifier).rotate,
      collapsed: collapsed,
      child: SizedBox(
        width: size,
        height: size,
        child: collapsed
            ? const Icon(Icons.arrow_upward_rounded)
            : Center(
                child: Icon(
                  Icons.grid_view,
                  size: size - (grid + 1) * 2,
                ),
              ),
      ),
    );
  }
}
