import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/presentation/hooks/markmayneedrebuild.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/settings/content_settings.dart';
import 'package:boorusphere/presentation/provider/settings/server_settings.dart';
import 'package:boorusphere/presentation/provider/settings/ui_settings.dart';
import 'package:boorusphere/presentation/routes/routes.dart';
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
      appBar: AppBar(title: Text(context.t.settings.title)),
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
          title: Text(context.t.downloads.title),
          children: [
            FutureBuilder(
              future: DownloadUtils.hasDotnomedia,
              initialData: false,
              builder: (context, snapshot) {
                final data = snapshot.data;
                final value = data is bool ? data : false;
                return SwitchListTile(
                  title: Text(context.t.settings.hideMedia.title),
                  subtitle: Padding(
                    padding: subtitlePadding,
                    child: Text(context.t.settings.hideMedia.desc),
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
          title: Text(context.t.settings.interface),
          children: [
            ListTile(
              title: Text(context.t.settings.lang.title),
              subtitle: Padding(
                padding: subtitlePadding,
                child: _CurrentLanguage(),
              ),
              onTap: () {
                context.router.push(const LanguageSettingsRoute());
              },
            ),
            SwitchListTile(
              title: Text(context.t.settings.midnightTheme.title),
              subtitle: Padding(
                padding: subtitlePadding,
                child: Text(context.t.settings.midnightTheme.desc),
              ),
              value: ref.watch(
                  uiSettingStateProvider.select((ui) => ui.midnightMode)),
              onChanged: (value) {
                ref
                    .watch(uiSettingStateProvider.notifier)
                    .setMidnightMode(value);
              },
            ),
            SwitchListTile(
              title: Text(context.t.settings.uiBlur.title),
              subtitle: Padding(
                padding: subtitlePadding,
                child: Text(context.t.settings.uiBlur.desc),
              ),
              value: ref.watch(uiSettingStateProvider.select((ui) => ui.blur)),
              onChanged: (value) {
                ref.watch(uiSettingStateProvider.notifier).showBlur(value);
              },
            ),
          ],
        ),
        _Section(
          title: Text(context.t.settings.safeMode),
          children: [
            SwitchListTile(
              title: Text(context.t.settings.blurContent.title),
              subtitle: Padding(
                padding: subtitlePadding,
                child: Text(context.t.settings.blurContent.desc),
              ),
              value: ref.watch(
                  contentSettingStateProvider.select((it) => it.blurExplicit)),
              onChanged: (value) {
                ref
                    .watch(contentSettingStateProvider.notifier)
                    .setBlurExplicitPost(value);
              },
            ),
            SwitchListTile(
              title: Text(context.t.settings.strictSafeMode.title),
              subtitle: Padding(
                padding: subtitlePadding,
                child: Text(context.t.settings.strictSafeMode.desc),
              ),
              value: ref.watch(
                  serverSettingsStateProvider.select((it) => it.safeMode)),
              onChanged: (value) {
                ref
                    .read(serverSettingsStateProvider.notifier)
                    .setSafeMode(value);
              },
            ),
          ],
        ),
        _Section(
          title: Text(context.t.servers.title),
          children: [
            SwitchListTile(
              title: Text(context.t.settings.loadOg.title),
              subtitle: Padding(
                padding: subtitlePadding,
                child: Text(context.t.settings.loadOg.desc),
              ),
              value: ref.watch(
                  contentSettingStateProvider.select((it) => it.loadOriginal)),
              onChanged: (value) {
                ref
                    .watch(contentSettingStateProvider.notifier)
                    .setLoadOriginalPost(value);
              },
            ),
            ListTile(
              title: Text(context.t.settings.postLimit.title),
              subtitle: Padding(
                padding: subtitlePadding,
                child: Text(context.t.settings.postLimit.desc),
              ),
              trailing: DropdownButton(
                menuMaxHeight: 178,
                value: ref.watch(
                    serverSettingsStateProvider.select((it) => it.postLimit)),
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
                      .read(serverSettingsStateProvider.notifier)
                      .setPostLimit(value as int);
                },
              ),
            ),
          ],
        ),
        _Section(
          title: Text(context.t.settings.misc),
          children: [
            ListTile(
              title: Text(context.t.settings.clearCache.title),
              subtitle: Padding(
                padding: subtitlePadding,
                child: Text(context.t.settings.clearCache.desc),
              ),
              onTap: () async {
                context.scaffoldMessenger.showSnackBar(SnackBar(
                  content: Text(context.t.clearing),
                  duration: const Duration(milliseconds: 500),
                ));

                await DefaultCacheManager().emptyCache();
                await extended_image.clearDiskCachedImages();
                extended_image.clearMemoryImageCache();

                context.scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(context.t.settings.clearCache.done),
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
    final locale = ref.watch(uiSettingStateProvider.select((ui) => ui.locale));

    return Text(
      locale == null
          ? context.t.settings.lang.auto.title
          : context.t.languageName,
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
