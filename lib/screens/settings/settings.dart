import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../providers/settings/blur_explicit_post.dart';
import '../../../providers/settings/safe_mode.dart';
import '../../../providers/settings/theme.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeMode = ref.watch(safeModeProvider);
    final darkerTheme = ref.watch(darkerThemeProvider);
    final blurExplicitPost = ref.watch(blurExplicitPostProvider);

    final themeSettings = SettingsThemeData(
        titleTextColor: Theme.of(context).colorScheme.primary,
        settingsListBackground: Colors.transparent);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SettingsList(
        lightTheme: themeSettings,
        darkTheme: themeSettings,
        sections: [
          SettingsSection(
            title: const Text('Interface'),
            tiles: [
              SettingsTile.switchTile(
                title: const Text('Darker Theme'),
                description:
                    const Text('Use deeper dark color for the dark mode'),
                leading: const Icon(Icons.brightness_3),
                initialValue: darkerTheme,
                onToggle: (value) {
                  ref.read(darkerThemeProvider.notifier).enable(value);
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Safe Mode'),
            tiles: [
              SettingsTile.switchTile(
                title: const Text('Blur explicit content'),
                description:
                    const Text('Content rated as explicit will be blurred'),
                leading: const Icon(Icons.phonelink_lock),
                initialValue: blurExplicitPost,
                onToggle: (value) {
                  ref.read(blurExplicitPostProvider.notifier).enable(value);
                },
              ),
              SettingsTile.switchTile(
                title: const Text('Rated safe only'),
                description: const Text(
                    'Only fetch content that rated as safe. Note that rated as safe doesn\'t guarantee "safe for work"'),
                leading: const Icon(Icons.phonelink_lock),
                initialValue: safeMode,
                onToggle: (value) {
                  ref.read(safeModeProvider.notifier).enable(value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
