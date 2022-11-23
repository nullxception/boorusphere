import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/app_updater.dart';
import 'package:boorusphere/presentation/provider/app_versions/app_versions_state.dart';
import 'package:boorusphere/presentation/provider/booru/page_state.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:boorusphere/presentation/routes/app_router.dart';
import 'package:boorusphere/presentation/screens/home/drawer/home_drawer_controller.dart';
import 'package:boorusphere/presentation/widgets/favicon.dart';
import 'package:boorusphere/presentation/widgets/prepare_update.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key, required this.maxWidth});

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
          title: Text(context.t.downloads.title),
          leading: const Icon(Icons.cloud_download),
          onTap: () => context.router.push(const DownloadsRoute()),
        ),
        ListTile(
          title: Text(context.t.favorites.title),
          leading: const Icon(Icons.favorite_border),
          onTap: () => context.router.push(const FavoritesRoute()),
        ),
        ListTile(
          title: Text(context.t.servers.title),
          leading: const Icon(Icons.public),
          onTap: () => context.router.push(const ServerRoute()),
        ),
        ListTile(
          title: Text(context.t.tagsBlocker.title),
          leading: const Icon(Icons.block),
          onTap: () => context.router.push(const TagsBlockerRoute()),
        ),
        ListTile(
          title: Text(context.t.settings.title),
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
    final theme =
        ref.watch(uiSettingStateProvider.select((ui) => ui.themeMode));

    return IconButton(
      icon: Icon(themeIconOf(theme)),
      onPressed: () =>
          ref.read(uiSettingStateProvider.notifier).cycleThemeMode(),
    );
  }
}

class AppVersionTile extends HookConsumerWidget {
  const AppVersionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersions = ref.watch(appVersionsStateProvider);
    final updateProgress = ref.watch(appUpdateProgressProvider);

    final currentTile = ListTile(
      title: appVersions.maybeWhen(
        data: (data) => Text('Boorusphere ${data.current}'),
        orElse: () => const Text('Boorusphere'),
      ),
      leading: const Icon(Icons.info_outline),
      onTap: () => context.router.push(const AboutRoute()),
    );

    return appVersions.maybeWhen(
      data: (data) {
        if (!data.latest.isNewerThan(data.current)) return currentTile;
        if (updateProgress.status.isDownloading) {
          return ListTile(
            title: Text(context.t.updater.available(version: '${data.latest}')),
            leading: const SizedBox(
              height: 24,
              width: 24,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
            subtitle: Text(
                context.t.updater.progress(progress: updateProgress.progress)),
            onTap: () => context.router.push(const AboutRoute()),
          );
        }
        return ListTile(
          title: Text(context.t.updater.available(version: '${data.latest}')),
          leading: Icon(Icons.info_outline, color: Colors.pink.shade300),
          subtitle: Text(
            updateProgress.status.isDownloaded
                ? context.t.updater.install
                : context.t.changelog.view,
          ),
          onTap: () {
            if (updateProgress.status.isDownloaded) {
              UpdatePrepareDialog.show(context);
            } else {
              context.router.push(const AboutRoute());
            }
          },
        );
      },
      orElse: () => currentTile,
    );
  }
}

class _BackToHomeTile extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query =
        ref.watch(pageStateProvider.select((it) => it.data.option.query));
    return Visibility(
      visible: query.isNotEmpty,
      child: ListTile(
        title: Text(context.t.goHome),
        leading: const Icon(Icons.home_outlined),
        onTap: () {
          ref
              .read(pageStateProvider.notifier)
              .update((state) => state.copyWith(query: '', clear: true));
          ref.read(homeDrawerController).close();
        },
      ),
    );
  }
}

class _ServerSelection extends HookConsumerWidget {
  const _ServerSelection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverData = ref.watch(serverDataStateProvider);
    final serverActive =
        ref.watch(serverSettingStateProvider.select((it) => it.active));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: serverData.map((it) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: ListTile(
            title: Text(it.name),
            leading: Favicon(
              url: it.homepage,
              shape: BoxShape.circle,
              iconSize: 21,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            selected: it.id == serverActive.id,
            selectedTileColor: context.colorScheme.primary
                .withAlpha(context.isLightThemed ? 50 : 25),
            onTap: () {
              ref.read(serverSettingStateProvider.notifier).setActiveServer(it);
              ref.read(homeDrawerController).close();
            },
          ),
        );
      }).toList(),
    );
  }
}
