part of 'home.dart';

class _Drawer extends StatelessWidget {
  const _Drawer({required this.maxWidth});
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
                      dense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
          onTap: () => context.router.push(const DownloadsRoute()),
        ),
        ListTile(
          title: const Text('Favorites'),
          leading: const Icon(Icons.favorite_border),
          onTap: () => context.router.push(const FavoritesRoute()),
        ),
        ListTile(
          title: const Text('Server'),
          leading: const Icon(Icons.public),
          onTap: () => context.router.push(const ServerRoute()),
        ),
        ListTile(
          title: const Text('Tags Blocker'),
          leading: const Icon(Icons.block),
          onTap: () => context.router.push(const TagsBlockerRoute()),
        ),
        ListTile(
          title: const Text('Settings'),
          leading: const Icon(Icons.settings),
          onTap: () => context.router.push(const SettingsRoute()),
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
      onPressed: ref.read(themeModeProvider.notifier).cycle,
    );
  }
}

class AppVersionTile extends HookConsumerWidget {
  const AppVersionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentVer = ref.watch(versionCurrentProvider
        .select((it) => it.maybeValue ?? AppVersion.zero));
    final latestVer = ref.watch(versionLatestProvider);
    final updater =
        ref.watch(downloadProvider.select((it) => it.appUpdateProgress));

    final updateStatus = updater.status;
    final current = ListTile(
      title: Text('Boorusphere $currentVer'),
      leading: const Icon(Icons.info_outline),
      onTap: () => context.router.push(const AboutRoute()),
    );

    return latestVer.maybeWhen(
      data: (data) {
        if (!data.isNewerThan(currentVer)) return current;
        if (updateStatus.isDownloading) {
          return ListTile(
            title: Text('Update available: $data'),
            leading: const SizedBox(
              height: 24,
              width: 24,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
            subtitle: Text('Downloading ${updater.progress}%'),
            onTap: () => context.router.push(const AboutRoute()),
          );
        }
        return ListTile(
          title: Text('Update available: $data'),
          leading: Icon(Icons.info_outline, color: Colors.pink.shade300),
          subtitle: Text(
            updater.status.isDownloaded ? 'Tap to install' : 'Tap to view',
          ),
          onTap: () {
            if (updater.status.isDownloaded) {
              UpdatePrepareDialog.show(context);
            } else {
              context.router.push(const AboutRoute());
            }
          },
        );
      },
      orElse: () => current,
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
    final serverActive = ref.watch(serverActiveProvider);

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
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            selected: it.name == serverActive.name,
            selectedTileColor: context.colorScheme.primary
                .withAlpha(context.isLightThemed ? 50 : 25),
            onTap: () {
              ref.read(serverActiveProvider.notifier).update(it);
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
