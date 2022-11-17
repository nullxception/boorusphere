import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/device_prop.dart';
import 'package:boorusphere/presentation/provider/settings/ui/language.dart';
import 'package:boorusphere/presentation/provider/settings/ui/theme.dart';
import 'package:boorusphere/presentation/routes/routes.dart';
import 'package:boorusphere/presentation/widgets/app_theme_builder.dart';
import 'package:boorusphere/presentation/widgets/bouncing_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Boorusphere extends HookConsumerWidget {
  const Boorusphere({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageSettingStateProvider);
    final themeMode = ref.watch(themeModeSettingStateProvider);
    final isDarkerTheme = ref.watch(midnightModeSettingStateProvider);
    final deviceProp = ref.watch(devicePropProvider);
    final router = useMemoized(SphereRouter.new);

    useEffect(() {
      Future(() {
        if (language != null) {
          LocaleSettings.setLocale(language);
        } else {
          LocaleSettings.useDeviceLocale();
        }
      });
    }, [language]);

    if (deviceProp.sdkVersion > 28) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return AppThemeBuilder(
      builder: (context, appTheme) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Boorusphere',
        theme: appTheme.day,
        darkTheme: isDarkerTheme ? appTheme.midnight : appTheme.night,
        themeMode: themeMode,
        routerDelegate: router.delegate(),
        routeInformationParser: router.defaultRouteParser(),
        locale: TranslationProvider.of(context).flutterLocale,
        supportedLocales: LocaleSettings.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, child) => ScrollConfiguration(
          behavior: const BouncingScrollBehavior(),
          child: child ?? Container(),
        ),
      ),
    );
  }
}
