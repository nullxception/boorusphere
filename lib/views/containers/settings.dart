import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../provider/common.dart';
import '../../routes.dart';

class Settings extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final server = useProvider(serverProvider);
    final sectionTitleStyle = TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontWeight: FontWeight.bold,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SettingsList(
        shrinkWrap: true,
        backgroundColor: Colors.transparent,
        darkBackgroundColor: Colors.transparent,
        sections: [
          SettingsSection(
            title: 'Server',
            titleTextStyle: sectionTitleStyle,
            titlePadding: const EdgeInsets.all(20),
            tiles: [
              SettingsTile.switchTile(
                title: 'Safe Mode',
                subtitleMaxLines: 5,
                subtitle:
                    'Fetch content that are safe.\nNote that rated "safe" on booru-powered site doesn\'t mean "Safe For Work".',
                leading: const Icon(Icons.phonelink_lock),
                switchValue: server.useSafeMode,
                onToggle: (value) {
                  server.setSafeMode(value);
                },
              ),
            ],
          ),
          SettingsSection(
            title: 'Misc',
            titleTextStyle: sectionTitleStyle,
            titlePadding: const EdgeInsets.all(20),
            tiles: [
              SettingsTile(
                title: 'Open source licenses',
                leading: const Icon(Icons.collections_bookmark),
                onPressed: (context) =>
                    Navigator.pushNamed(context, Routes.licenses),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
