part of 'home.dart';

class _Drawer extends StatelessWidget {
  const _Drawer({super.key, required this.maxWidth});
  final double maxWidth;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.drawerTheme.backgroundColor,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(25),
        bottomRight: Radius.circular(25),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: constraints.copyWith(
                minHeight: constraints.maxHeight,
                maxHeight: double.infinity,
                maxWidth: maxWidth,
              ),
              child: IntrinsicHeight(
                child: SafeArea(
                  child: ListTileTheme(
                    data: context.theme.listTileTheme.copyWith(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: Flex(
                      direction: Axis.vertical,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              _Header(),
                              _ServerSelection(),
                            ],
                          ),
                        ),
                        const Expanded(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: _Footer(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _BackToHomeTile(),
        ListTile(
          title: const Text('Downloads'),
          leading: const Icon(Icons.cloud_download),
          dense: true,
          onTap: () => context.goNamed('downloads'),
        ),
        ListTile(
          title: const Text('Server'),
          leading: const Icon(Icons.public),
          dense: true,
          onTap: () => context.goNamed('servers'),
        ),
        ListTile(
          title: const Text('Tags Blocker'),
          leading: const Icon(Icons.block),
          dense: true,
          onTap: () => context.goNamed('tags-blocker'),
        ),
        ListTile(
          title: const Text('Settings'),
          leading: const Icon(Icons.settings),
          dense: true,
          onTap: () => context.goNamed('settings'),
        ),
        const AppVersionTile(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Boorusphere!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w200,
            ),
          ),
          _ThemeSwitcherButton(),
        ],
      ),
    );
  }
}

class _ThemeSwitcherButton extends HookConsumerWidget {
  IconData themeIconOf(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return Icons.brightness_2;
      case ThemeMode.light:
        return Icons.brightness_high;
      default:
        return Icons.brightness_auto;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return IconButton(
      icon: Icon(themeIconOf(themeMode)),
      onPressed: ref.read(themeModeProvider.notifier).cycleTheme,
    );
  }
}

class AppVersionTile extends HookConsumerWidget {
  const AppVersionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionData = ref.watch(versionDataProvider);
    final versionUpdate = ref.watch(versionUpdateProvider);
    return versionUpdate.maybeWhen(
      data: (data) {
        return ListTile(
          title: Text(data.shouldUpdate
              ? 'Update available: ${data.newVersion}'
              : 'Boorusphere ${data.currentVersion}'),
          leading: Icon(
            Icons.info_outline,
            color: data.shouldUpdate ? Colors.pink.shade300 : null,
          ),
          dense: true,
          onTap: () => context.goNamed('about'),
        );
      },
      orElse: () => ListTile(
        title: Text('Boorusphere ${versionData.version}'),
        leading: const Icon(Icons.info_outline),
        dense: true,
        onTap: () => context.goNamed('about'),
      ),
    );
  }
}

class _BackToHomeTile extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageQuery =
        ref.watch(pageOptionProvider.select((value) => value.query));

    return Visibility(
      visible: pageQuery.isNotEmpty,
      child: ListTile(
        title: const Text('Back to home'),
        leading: const Icon(Icons.home_outlined),
        dense: true,
        onTap: () {
          ref
              .read(pageOptionProvider.notifier)
              .update((state) => const PageOption(clear: true));
          ref.read(slidingDrawerController).close();
        },
      ),
    );
  }
}

class _ServerSelection extends HookConsumerWidget {
  const _ServerSelection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverData = ref.watch(serverDataProvider);
    final activeServer = ref.watch(activeServerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: serverData.map((it) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: ListTile(
            title: Text(it.name),
            leading: Favicon(
              url: '${it.homepage}/favicon.ico',
              shape: BoxShape.circle,
              iconSize: 21,
            ),
            dense: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            selected: it.name == activeServer.name,
            selectedTileColor: context.colorScheme.primary
                .withAlpha(context.isLightThemed ? 50 : 25),
            onTap: () {
              ref.read(activeServerProvider.notifier).use(it);
              ref
                  .read(pageOptionProvider.notifier)
                  .update((state) => state.copyWith(clear: true));
              ref.read(slidingDrawerController).close();
            },
          ),
        );
      }).toList(),
    );
  }
}
