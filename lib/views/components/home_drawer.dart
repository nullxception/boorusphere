import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/server_data.dart';
import '../../provider/app_theme.dart';
import '../../provider/app_version.dart';
import '../../provider/booru_api.dart';
import '../../provider/booru_query.dart';
import '../../provider/server_data.dart';
import '../../routes.dart';
import 'favicon.dart';

class HomeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
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
                            const Divider(),
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
                                title: const Text('Blocked Tags'),
                                leading: const Icon(Icons.block),
                                dense: true,
                                onTap: () => Navigator.pushNamed(
                                    context, Routes.tagsBlocker),
                              ),
                              ListTile(
                                title: const Text('Settings'),
                                leading: const Icon(Icons.settings),
                                dense: true,
                                onTap: () => Navigator.pushNamed(
                                    context, Routes.settings),
                              ),
                              AppVersionTile(),
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeHandler = ref.watch(appThemeProvider.notifier);

    return IconButton(
      icon: Icon(appThemeHandler.themeIcon),
      onPressed: appThemeHandler.cycleTheme,
    );
  }
}

class AppVersionTile extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider);
    return ListTile(
      title: Text(version.shouldUpdate
          ? 'Update available: ${version.lastestVersion}'
          : 'Boorusphere ${version.version}'),
      subtitle:
          version.shouldUpdate ? const Text('Click here to download') : null,
      leading: Icon(
        Icons.info_outline,
        color: version.shouldUpdate ? Colors.pink.shade300 : null,
      ),
      dense: true,
      onTap: version.shouldUpdate ? () => launch(version.downloadUrl) : null,
    );
  }
}

class _BackToHomeTile extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(booruApiProvider);
    final booruQuery = ref.watch(booruQueryProvider);
    final booruQueryNotifier = ref.watch(booruQueryProvider.notifier);

    return Visibility(
      visible: booruQuery.tags != ServerData.defaultTag,
      child: ListTile(
        title: const Text('Back to home'),
        leading: const Icon(Icons.home_outlined),
        dense: true,
        onTap: () {
          booruQueryNotifier.setTag(query: ServerData.defaultTag);
          api.posts.clear();
          api.fetch();
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _ServerSelection extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(booruApiProvider);
    final server = ref.watch(serverDataProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: server.all.map((it) {
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
            selected: it.name == server.active.name,
            selectedTileColor: theme.colorScheme.secondary
                .withAlpha(theme.brightness == Brightness.light ? 50 : 25),
            onTap: () {
              server.setActiveServer(name: it.name);
              api.posts.clear();
              api.fetch();
              Navigator.pop(context);
            },
          ),
        );
      }).toList(),
    );
  }
}
