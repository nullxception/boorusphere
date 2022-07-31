import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../providers/settings/blur_explicit_post.dart';
import '../../../providers/settings/safe_mode.dart';
import '../../../providers/settings/theme.dart';
import '../../providers/settings/server/post_limit.dart';
import '../../utils/download.dart';
import '../../utils/extensions/buildcontext.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeMode = ref.watch(safeModeProvider);
    final darkerTheme = ref.watch(darkerThemeProvider);
    final blurExplicitPost = ref.watch(blurExplicitPostProvider);
    final postLimit = ref.watch(serverPostLimitProvider);
    final dotnomediaStatus = useFuture(DownloadUtils.hasDotnomedia);
    final themeSettings = SettingsThemeData(
        titleTextColor: context.colorScheme.primary,
        settingsListBackground: Colors.transparent);
    final messenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SettingsList(
        lightTheme: themeSettings,
        darkTheme: themeSettings,
        sections: [
          SettingsSection(
            title: const Text('Downloads'),
            tiles: [
              SettingsTile.switchTile(
                title: const Text('Hide downloaded media'),
                description: const Text(
                    'Prevent external gallery app from showing downloaded files'),
                leading: const Icon(Icons.security_rounded),
                initialValue: dotnomediaStatus.data,
                onToggle: (isEnabled) {
                  isEnabled
                      ? DownloadUtils.createDotnomedia()
                      : DownloadUtils.removeDotnomedia();
                },
              ),
            ],
          ),
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
          SettingsSection(
            title: const Text('Server'),
            tiles: [
              SettingsTile(
                title: const Text('Max result'),
                description: const Text(
                    'The number of results per page load. Default is ${ServerPostLimitState.defaultLimit}'),
                leading: const Icon(Icons.list),
                trailing: DropdownButton(
                  menuMaxHeight: 178,
                  value: postLimit,
                  items: List<DropdownMenuItem<int>>.generate(10, (i) {
                    final x = i * 10 + 10;
                    return DropdownMenuItem(value: x, child: Text('$x'));
                  }),
                  onChanged: (value) {
                    ref
                        .read(serverPostLimitProvider.notifier)
                        .save(value as int);
                  },
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Miscellaneous'),
            tiles: [
              SettingsTile(
                title: const Text('Clear cache'),
                description: const Text('Clear loaded content from cache'),
                leading: const Icon(Icons.delete),
                onPressed: (context) async {
                  messenger.showSnackBar(const SnackBar(
                    content: Text('Clearing...'),
                    duration: Duration(seconds: 1),
                  ));
                  await clearDiskCachedImages();
                  clearMemoryImageCache();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
