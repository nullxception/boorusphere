import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../entity/page_option.dart';
import '../../settings/active_server.dart';
import '../../settings/theme.dart';
import '../../source/page.dart';
import '../../source/server.dart';
import '../../source/version.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../widgets/favicon.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: constraints.copyWith(
                minHeight: constraints.maxHeight,
                maxHeight: double.infinity,
              ),
              child: IntrinsicHeight(
                child: SafeArea(
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(15, 30, 15, 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                            ),
                            _ServerSelection(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Divider(),
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
                          ),
                        ),
                      ),
                    ],
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
          context.navigator.pop();
        },
      ),
    );
  }
}

class _ServerSelection extends HookConsumerWidget {
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
            leading: Favicon(url: '${it.homepage}/favicon.ico'),
            dense: true,
            contentPadding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
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
              context.navigator.pop();
            },
          ),
        );
      }).toList(),
    );
  }
}
