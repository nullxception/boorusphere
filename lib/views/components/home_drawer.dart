import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../provider/common.dart';
import '../../routes.dart';

class HomeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  child: _ThemeSwitcherButton(),
                ),
                const Text(
                  'Boorusphere!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ],
            ),
            decoration: const BoxDecoration(color: Colors.blue),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: _ServerSelection(),
          ),
          const Divider(),
          ListTile(
            title: const Text('Settings'),
            onTap: () => Navigator.pushNamed(context, Routes.settings),
          ),
        ],
      ),
    );
  }
}

class _ThemeSwitcherButton extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final uiTheme = useProvider(uiThemeProvider);
    final uiThemeHandler = useProvider(uiThemeProvider.notifier);
    return IconButton(
      icon: Icon(
        uiTheme != ThemeMode.dark ? Icons.wb_sunny : Icons.wb_incandescent,
      ),
      onPressed: uiThemeHandler.toggle,
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

    return DropdownButton(
      underline: const SizedBox.shrink(),
      isExpanded: true,
      iconSize: 30.0,
      value: activeServer.name,
      items: serverList
          .map((it) => DropdownMenuItem(value: it.name, child: Text(it.name)))
          .toList(),
      onChanged: (name) {
        if (name is String) {
          activeServerHandler.setActiveServer(name: name);
          api.fetch(clear: true);
          Navigator.pop(context);
        }
      },
    );
  }
}
