import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage()
class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.settings.lang.title)),
      body: const SafeArea(child: _Content()),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const subtitlePadding = EdgeInsets.only(top: 8);

    updateLocale(AppLocale? locale) async {
      await ref.read(uiSettingStateProvider.notifier).setLocale(locale);
      Future.delayed(
        const Duration(milliseconds: 120),
        () => context.router.pop(),
      );
    }

    return ListView(
      children: [
        ListTile(
          title: Text(context.t.auto),
          subtitle: Padding(
            padding: subtitlePadding,
            child: Text(context.t.settings.lang.auto),
          ),
          onTap: () {
            updateLocale(null);
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
              updateLocale(locale);
            },
          );
        }).toList()
      ],
    );
  }
}
