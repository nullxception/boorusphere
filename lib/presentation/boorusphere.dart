import 'dart:io';

import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/i18n/helper.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/download/download_state.dart';
import 'package:boorusphere/presentation/provider/download/flutter_downloader_handle.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:boorusphere/presentation/routes/app_route_observer.dart';
import 'package:boorusphere/presentation/routes/app_router.dart';
import 'package:boorusphere/presentation/widgets/app_theme_builder.dart';
import 'package:boorusphere/utils/file_utils.dart';
import 'package:boorusphere/utils/http/overrides.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Boorusphere extends HookConsumerWidget {
  const Boorusphere({super.key});

  Future<void> initializeAsyncStates(
    WidgetRef ref,
    Function onCompleted,
  ) async {
    await ref.read(serverDataStateProvider.notifier).populate();
    await ref.read(downloadStateProvider.notifier).populate();
    await FlutterDisplayMode.setHighRefreshRate();
    onCompleted();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(uiSettingStateProvider.select((ui) => ui.locale));
    final theme =
        ref.watch(uiSettingStateProvider.select((ui) => ui.themeMode));
    final isMidnight =
        ref.watch(uiSettingStateProvider.select((ui) => ui.midnightMode));
    final envRepo = ref.watch(envRepoProvider);
    final cookieJar = ref.watch(cookieJarProvider);
    final router = useMemoized(AppRouter.new);
    final initialized = useState(false);

    useEffect(() {
      initializeAsyncStates(ref, () {
        initialized.value = true;
      });
    }, []);

    if (!initialized.value) {
      return const SizedBox.shrink();
    }

    useEffect(() {
      HttpOverrides.global = CustomHttpOverrides(cookieJar: cookieJar);
      return () {
        HttpOverrides.global = null;
      };
    }, [cookieJar]);

    useEffect(() {
      LocaleHelper.update(locale);
    }, [locale]);

    useEffect(() {
      ref.read(downloaderHandleProvider).listen((progress) {
        ref.read(downloadStateProvider.notifier).updateProgress(progress);
        if (progress.status.isDownloaded) {
          FileUtils.rescanDownloadDir();
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
        routerConfig: router.config(
          navigatorObservers: () => [
            AppRouteObserver(ref),
          ],
        ),
        locale: TranslationProvider.of(context).locale.digestedFlutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, child) => child ?? Container(),
      ),
    );
  }
}

// Convert slang locale to flutter locale
extension on AppLocale {
  Locale get digestedFlutterLocale {
    if (this == AppLocale.uwu) {
      return AppLocale.en.flutterLocale;
    }

    // Return the actual locale
    return flutterLocale;
  }
}
