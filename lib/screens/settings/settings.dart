import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../hooks/markmayneedrebuild.dart';
import '../../settings/blur_explicit_post.dart';
import '../../settings/safe_mode.dart';
import '../../settings/server/post_limit.dart';
import '../../settings/theme.dart';
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
    final markMayNeedRebuild = useMarkMayNeedRebuild();

    const sectionPadding = EdgeInsets.fromLTRB(18, 12, 18, 12);
    final sectionStyle = context.theme.textTheme.subtitle2!
        .copyWith(color: context.colorScheme.primary);
    const subtitlePadding = EdgeInsets.only(top: 8, bottom: 8);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Theme(
        data: context.theme.copyWith(
          listTileTheme: context.theme.listTileTheme.copyWith(
            minVerticalPadding: 12,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18),
          ),
        ),
        child: SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: sectionPadding,
                child: Text(
                  'Downloads',
                  style: sectionStyle,
                ),
              ),
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
              Padding(
                padding: sectionPadding,
                child: Text(
                  'Interface',
                  style: sectionStyle,
                ),
              ),
              SwitchListTile(
                title: const Text('Darker Theme'),
                subtitle: const Padding(
                  padding: subtitlePadding,
                  child: Text('Use deeper dark color for the dark mode'),
                ),
                value: darkerTheme,
                onChanged: (value) {
                  ref.read(darkerThemeProvider.notifier).enable(value);
                },
              ),
              Padding(
                padding: sectionPadding,
                child: Text(
                  'Safe mode',
                  style: sectionStyle,
                ),
              ),
              SwitchListTile(
                title: const Text('Blur explicit content'),
                subtitle: const Padding(
                  padding: subtitlePadding,
                  child: Text('Content rated as explicit will be blurred'),
                ),
                value: blurExplicitPost,
                onChanged: (value) {
                  ref.read(blurExplicitPostProvider.notifier).enable(value);
                },
              ),
              SwitchListTile(
                title: const Text('Rated safe only'),
                subtitle: const Padding(
                  padding: subtitlePadding,
                  child: Text(
                      'Only fetch content that rated as safe. Note that rated as safe doesn\'t guarantee "safe for work"'),
                ),
                value: safeMode,
                onChanged: (value) {
                  ref.read(safeModeProvider.notifier).enable(value);
                },
              ),
              Padding(
                padding: sectionPadding,
                child: Text(
                  'Server',
                  style: sectionStyle,
                ),
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
                  value: postLimit,
                  elevation: 0,
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
                        .read(serverPostLimitProvider.notifier)
                        .save(value as int);
                  },
                ),
              ),
              Padding(
                padding: sectionPadding,
                child: Text(
                  'Miscellaneous',
                  style: sectionStyle,
                ),
              ),
              ListTile(
                title: const Text('Clear cache'),
                subtitle: const Padding(
                  padding: subtitlePadding,
                  child: Text('Clear loaded content from cache'),
                ),
                onTap: () {
                  context.scaffoldMessenger.showSnackBar(const SnackBar(
                    content: Text('Clearing...'),
                    duration: Duration(seconds: 1),
                  ));
                  clearDiskCachedImages()
                      .then((value) => clearMemoryImageCache());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
