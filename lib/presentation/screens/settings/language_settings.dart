import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/settings/ui/ui_settings.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.settings.lang.title)),
      body: const SafeArea(child: _Content()),
    );
  }
}

class _Content extends HookConsumerWidget {
  const _Content();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const subtitlePadding = EdgeInsets.only(top: 8);

    useLanguage(AppLocale? lang) async {
      await ref.read(UiSettingsProvider.lang.notifier).update(lang);
      Future.delayed(
        const Duration(milliseconds: 120),
        () => context.router.pop(),
      );
    }

    return ListView(
      children: [
        ListTile(
          title: Text(t.settings.lang.automatic.title),
          subtitle: Padding(
            padding: subtitlePadding,
            child: Text(t.settings.lang.automatic.desc),
          ),
          onTap: () {
            useLanguage(null);
          },
        ),
        ...AppLocale.values.map((locale) {
          return ListTile(
            title: Text(locale.translations.languageName),
            subtitle: Padding(
              padding: subtitlePadding,
              child: Text(locale.translations.languageAlias),
            ),
            onTap: () {
              useLanguage(locale);
            },
          );
        }).toList()
      ],
    );
  }
}
