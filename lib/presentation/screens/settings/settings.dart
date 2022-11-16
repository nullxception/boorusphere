import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/presentation/hooks/markmayneedrebuild.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/settings/content/content_settings.dart';
import 'package:boorusphere/presentation/provider/settings/server/server_settings.dart';
import 'package:boorusphere/presentation/provider/settings/ui/ui_settings.dart';
import 'package:boorusphere/presentation/routes/routes.dart';
import 'package:boorusphere/utils/download.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:extended_image/extended_image.dart' as extended_image;
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final localeProvider =
    StreamProvider((ref) => LocaleSettings.getLocaleStream());

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(t.settings.title)),
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
          title: Text(t.downloader.title),
          children: [
            FutureBuilder(
              future: DownloadUtils.hasDotnomedia,
              initialData: false,
              builder: (context, snapshot) {
                final data = snapshot.data;
                final value = data is bool ? data : false;
                return SwitchListTile(
                  title: Text(t.settings.hideMedia.title),
                  subtitle: Padding(
                    padding: subtitlePadding,
                    child: Text(t.settings.hideMedia.desc),
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
          title: Text(t.settings.interface),
          children: [
            ListTile(
              title: Text(t.settings.lang.title),
              subtitle: Padding(
                padding: subtitlePadding,
                child: _CurrentLanguage(),
              ),
              onTap: () {
                context.router.push(const LanguageSettingsRoute());
              },
            ),
            SwitchListTile(
              title: Text(t.settings.midnightTheme.title),
              subtitle: Padding(
                padding: subtitlePadding,
                child: Text(t.settings.midnightTheme.desc),
              ),
              value: ref.watch(UiSettingsProvider.darkerTheme),
              onChanged: (value) {
                ref
                    .watch(UiSettingsProvider.darkerTheme.notifier)
                    .update(value);
              },
            ),
            SwitchListTile(
              title: Text(t.settings.uiBlur.title),
              subtitle: Padding(
                padding: subtitlePadding,
                child: Text(t.settings.uiBlur.desc),
              ),
              value: ref.watch(UiSettingsProvider.blur),
              onChanged: (value) {
                ref.watch(UiSettingsProvider.blur.notifier).enable(value);
              },
            ),
          ],
        ),
        _Section(
          title: Text(t.settings.safeMode),
          children: [
            SwitchListTile(
              title: Text(t.settings.blurContent.title),
              subtitle: Padding(
                padding: subtitlePadding,
                child: Text(t.settings.blurContent.desc),
              ),
              value: ref.watch(ContentSettingsProvider.blurExplicit),
              onChanged: (value) {
                ref
                    .watch(ContentSettingsProvider.blurExplicit.notifier)
                    .update(value);
              },
            ),
            SwitchListTile(
              title: Text(t.settings.strictSafeMode.title),
              subtitle: Padding(
                padding: subtitlePadding,
                child: Text(t.settings.strictSafeMode.desc),
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
          title: Text(t.servers.title),
          children: [
            SwitchListTile(
              title: Text(t.settings.loadOG.title),
              subtitle: Padding(
                padding: subtitlePadding,
                child: Text(t.settings.loadOG.desc),
              ),
              value: ref.watch(ContentSettingsProvider.loadOriginal),
              onChanged: (value) {
                ref
                    .watch(ContentSettingsProvider.loadOriginal.notifier)
                    .update(value);
              },
            ),
            ListTile(
              title: Text(t.settings.postLimit.title),
              subtitle: Padding(
                padding: subtitlePadding,
                child: Text(t.settings.postLimit.desc),
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
          title: Text(t.settings.misc),
          children: [
            ListTile(
              title: Text(t.settings.clearCache.title),
              subtitle: Padding(
                padding: subtitlePadding,
                child: Text(t.settings.clearCache.desc),
              ),
              onTap: () async {
                context.scaffoldMessenger.showSnackBar(SnackBar(
                  content: Text(t.clearing),
                  duration: const Duration(milliseconds: 500),
                ));

                await DefaultCacheManager().emptyCache();
                await extended_image.clearDiskCachedImages();
                extended_image.clearMemoryImageCache();

                context.scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(t.settings.clearCache.done),
                    duration: const Duration(milliseconds: 500),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _CurrentLanguage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(UiSettingsProvider.lang);
    return Text(
      language == null ? t.settings.lang.automatic.title : t.languageName,
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
