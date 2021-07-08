import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../provider/common.dart';
import '../../routes.dart';

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
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 25),
                              child: Text(
                                'Boorusphere!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w200,
                                ),
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
                              _ThemeSwitcherButton(),
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

class AppVersionTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final version = useProvider(versionProvider);
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

class _ThemeSwitcherButton extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final uiThemeHandler = useProvider(uiThemeProvider.notifier);
    final uiTheme = useProvider(uiThemeProvider);
    final uiThemeGroup = {
      'Dark': ThemeMode.dark,
      'Light': ThemeMode.light,
      'System wide': ThemeMode.system,
    };

    return ListTile(
      title: const Text('Switch theme'),
      leading: Icon(uiThemeHandler.icon),
      dense: true,
      onTap: () => showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: uiThemeGroup
                .map((key, value) {
                  return MapEntry(
                    key,
                    RadioListTile(
                      value: value,
                      groupValue: uiTheme,
                      onChanged: (value) {
                        if (value is ThemeMode) {
                          uiThemeHandler.setMode(mode: value);
                        }
                        Navigator.pop(context);
                      },
                      title: Text(key),
                    ),
                  );
                })
                .values
                .toList(),
          );
        },
      ),
    );
  }
}

class _ServerSelection extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final api = useProvider(apiProvider);
    final activeServer = useProvider(activeServerProvider);
    final activeServerHandler = useProvider(activeServerProvider.notifier);
    final serverList = useProvider(serverListProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: serverList.map((it) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: ListTile(
            title: Text(it.name),
            leading: const Icon(Icons.public),
            dense: true,
            contentPadding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            selected: it.name == activeServer.name,
            selectedTileColor: theme.colorScheme.secondary
                .withAlpha(theme.brightness == Brightness.light ? 50 : 25),
            onTap: () {
              activeServerHandler.setActiveServer(name: it.name);
              api.fetch(clear: true);
              Navigator.pop(context);
            },
          ),
        );
      }).toList(),
    );
  }
}
