import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/i18n/helper.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/download/download_state.dart';
import 'package:boorusphere/presentation/provider/download/flutter_downloader_handle.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:boorusphere/presentation/routes/app_router.dart';
import 'package:boorusphere/presentation/widgets/app_theme_builder.dart';
import 'package:boorusphere/presentation/widgets/bouncing_scroll.dart';
import 'package:boorusphere/utils/download.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Boorusphere extends HookConsumerWidget {
  const Boorusphere({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(uiSettingStateProvider.select((ui) => ui.locale));
    final theme =
        ref.watch(uiSettingStateProvider.select((ui) => ui.themeMode));
    final isMidnight =
        ref.watch(uiSettingStateProvider.select((ui) => ui.midnightMode));
    final envRepo = ref.watch(envRepoProvider);
    final router = useMemoized(AppRouter.new);

    useEffect(() {
      LocaleHelper.update(locale);
    }, [locale]);

    useEffect(() {
      ref.read(downloaderHandleProvider).listen((progress) {
        ref.read(downloadStateProvider.notifier).updateProgress(progress);
        if (progress.status.isDownloaded) {
          DownloadUtils.rescanMedia();
        }
      });
    }, []);

    if (envRepo.sdkVersion > 28) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return AppThemeBuilder(
      builder: (context, appTheme) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Boorusphere',
        theme: appTheme.day,
        darkTheme: isMidnight ? appTheme.midnight : appTheme.night,
        themeMode: theme,
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
