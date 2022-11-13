import 'package:boorusphere/presentation/hooks/markmayneedrebuild.dart';
import 'package:boorusphere/presentation/provider/settings/content/content_settings.dart';
import 'package:boorusphere/presentation/provider/settings/server/server_settings.dart';
import 'package:boorusphere/presentation/provider/settings/ui/ui_settings.dart';
import 'package:boorusphere/utils/download.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:extended_image/extended_image.dart' as extended_image;
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const SafeArea(
        child: _SettingsContent(),
      ),
    );
  }
}

class _SettingsContent extends HookConsumerWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markMayNeedRebuild = useMarkMayNeedRebuild();
    const subtitlePadding = EdgeInsets.only(top: 8);

    return ListView(
      children: [
        _Section(
          title: const Text('Downloads'),
          children: [
            FutureBuilder(
              future: DownloadUtils.hasDotnomedia,
              initialData: false,
              builder: (context, snapshot) {
                final data = snapshot.data;
                final value = data is bool ? data : false;
                return SwitchListTile(
                  title: const Text('Hide downloaded media'),
                  subtitle: const Padding(
                    padding: subtitlePadding,
                    child: Text(
                        'Prevent external gallery app from showing downloaded files'),
                  ),
                  value: value,
                  onChanged: (isEnabled) async {
                    isEnabled
                        ? await DownloadUtils.createDotnomedia()
                        : await DownloadUtils.removeDotnomedia();
                    markMayNeedRebuild();
                  },
                );
              },
            ),
          ],
        ),
        _Section(
          title: const Text('Interface'),
          children: [
            SwitchListTile(
              title: const Text('Darker Theme'),
              subtitle: const Padding(
                padding: subtitlePadding,
                child: Text('Use deeper dark color for the dark mode'),
              ),
              value: ref.watch(UiSettingsProvider.darkerTheme),
              onChanged: (value) {
                ref
                    .watch(UiSettingsProvider.darkerTheme.notifier)
                    .update(value);
              },
            ),
            SwitchListTile(
              title: const Text('Enable blur'),
              subtitle: const Padding(
                padding: subtitlePadding,
                child: Text('Enable blur background on various UI elements'),
              ),
              value: ref.watch(UiSettingsProvider.blur),
              onChanged: (value) {
                ref.watch(UiSettingsProvider.blur.notifier).enable(value);
              },
            ),
          ],
        ),
        _Section(
          title: const Text('Safe mode'),
          children: [
            SwitchListTile(
              title: const Text('Blur explicit content'),
              subtitle: const Padding(
                padding: subtitlePadding,
                child: Text('Content rated as explicit will be blurred'),
              ),
              value: ref.watch(ContentSettingsProvider.blurExplicit),
              onChanged: (value) {
                ref
                    .watch(ContentSettingsProvider.blurExplicit.notifier)
                    .update(value);
              },
            ),
            SwitchListTile(
              title: const Text('Rated safe only'),
              subtitle: const Padding(
                padding: subtitlePadding,
                child: Text(
                    'Only fetch content that rated as safe. Note that rated as safe doesn\'t guarantee "safe for work"'),
              ),
              value: ref.watch(ServerSettingsProvider.safeMode),
              onChanged: (value) {
                ref
                    .watch(ServerSettingsProvider.safeMode.notifier)
                    .update(value);
              },
            ),
          ],
        ),
        _Section(
          title: const Text('Server'),
          children: [
            SwitchListTile(
              title: const Text('Display original content'),
              subtitle: const Padding(
                padding: subtitlePadding,
                child: Text(
                    'Load original file instead of the sample when opening the post'),
              ),
              value: ref.watch(ContentSettingsProvider.loadOriginal),
              onChanged: (value) {
                ref
                    .watch(ContentSettingsProvider.loadOriginal.notifier)
                    .update(value);
              },
            ),
            ListTile(
              title: const Text('Max content per-load'),
              subtitle: const Padding(
                padding: subtitlePadding,
                child: Text(
                    'Result might less than expected (caused by blocked tags or invalid data)'),
              ),
              trailing: DropdownButton(
                menuMaxHeight: 178,
                value: ref.watch(ServerSettingsProvider.postLimit),
                elevation: 1,
                underline: const SizedBox.shrink(),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                items: List<DropdownMenuItem<int>>.generate(
                  10,
                  (i) {
                    final x = i * 10 + 10;
                    return DropdownMenuItem(
                      value: x,
                      child: Text('$x'),
                    );
                  },
                ),
                onChanged: (value) {
                  ref
                      .watch(ServerSettingsProvider.postLimit.notifier)
                      .update(value as int);
                },
              ),
            ),
          ],
        ),
        _Section(
          title: const Text('Miscellaneous'),
          children: [
            ListTile(
              title: const Text('Clear cache'),
              subtitle: const Padding(
                padding: subtitlePadding,
                child: Text('Clear loaded content from cache'),
              ),
              onTap: () async {
                context.scaffoldMessenger.showSnackBar(const SnackBar(
                  content: Text('Clearing...'),
                  duration: Duration(milliseconds: 500),
                ));

                await DefaultCacheManager().emptyCache();
                await extended_image.clearDiskCachedImages();
                extended_image.clearMemoryImageCache();

                context.scaffoldMessenger.showSnackBar(const SnackBar(
                  content: Text('Cache cleared'),
                  duration: Duration(milliseconds: 500),
                ));
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, this.children = const []});

  final Widget title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const sectionPadding = EdgeInsets.fromLTRB(22, 12, 22, 12);
    final sectionStyle = context.theme.textTheme.subtitle2!
        .copyWith(color: context.colorScheme.primary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: sectionPadding,
          child: DefaultTextStyle(
            style: sectionStyle,
            child: title,
          ),
        ),
        ...children,
      ],
    );
  }
}
