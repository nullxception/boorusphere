import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'entity/app_version.dart';
import 'entity/download_entry.dart';
import 'entity/post.dart';
import 'entity/search_history.dart';
import 'entity/server_data.dart';
import 'screens/about/about.dart';
import 'screens/about/changelog.dart';
import 'screens/about/licenses.dart';
import 'screens/downloads/downloads.dart';
import 'screens/home/home.dart';
import 'screens/server/server.dart';
import 'screens/server/server_edit.dart';
import 'screens/settings/settings.dart';
import 'screens/tags_blocker/tags_blocker.dart';
import 'services/app_theme/app_theme.dart';
import 'settings/theme.dart';
import 'source/changelog.dart';
import 'source/device_info.dart';

class Boorusphere extends HookConsumerWidget {
  Boorusphere({super.key});

  final _route = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            name: 'downloads',
            path: 'downloads',
            builder: (context, state) => const DownloadsPage(),
          ),
          GoRoute(
              name: 'servers',
              path: 'servers',
              builder: (context, state) => const ServerPage(),
              routes: [
                GoRoute(
                  name: 'add-server',
                  path: 'add',
                  builder: (context, state) => const ServerEditorPage(),
                ),
                GoRoute(
                  name: 'edit-server',
                  path: 'edit',
                  builder: (context, state) => ServerEditorPage(
                    server: state.extra as ServerData,
                  ),
                ),
              ]),
          GoRoute(
            name: 'tags-blocker',
            path: 'tags-blocker',
            builder: (context, state) => const TagsBlockerPage(),
          ),
          GoRoute(
            name: 'settings',
            path: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            name: 'about',
            path: 'about',
            builder: (context, state) => const AboutPage(),
            routes: [
              GoRoute(
                name: 'changelog',
                path: 'changelog',
                builder: (context, state) {
                  return const ChangelogPage(
                    option: ChangelogOption(
                      type: ChangelogType.assets,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    name: 'changelog/ver',
                    path: ':ver',
                    builder: (context, state) {
                      final ver = state.params['ver'];
                      final git = state.queryParams['git'] == '1';
                      return ChangelogPage(
                        option: ChangelogOption(
                          type: git ? ChangelogType.git : ChangelogType.assets,
                          version:
                              ver != null ? AppVersion.fromString(ver) : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                name: 'licenses',
                path: 'licenses',
                builder: (context, state) => const LicensesPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final appTheme = ref.watch(appThemeProvider);
    final isDarkerTheme = ref.watch(darkerThemeProvider);
    final deviceInfo = ref.watch(deviceInfoProvider);

    if (deviceInfo.sdkInt > 28) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return DynamicColorBuilder(
      builder: (maybeLight, maybeDark) {
        appTheme.overrideWith(light: maybeLight, dark: maybeDark);
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Boorusphere',
          theme: appTheme.data.day,
          darkTheme:
              isDarkerTheme ? appTheme.data.midnight : appTheme.data.night,
          themeMode: themeMode,
          routeInformationProvider: _route.routeInformationProvider,
          routeInformationParser: _route.routeInformationParser,
          routerDelegate: _route.routerDelegate,
        );
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const boxes = [
    'searchHistory',
    'settings',
    'server',
    'blockedTags',
    'downloads',
  ];

  await Hive.initFlutter();
  Hive.registerAdapter(ServersAdapter());
  Hive.registerAdapter(SearchHistoryAdapter());
  Hive.registerAdapter(PostAdapter());
  Hive.registerAdapter(DownloadEntryAdapter());
  await Future.wait(boxes.map(Hive.openBox));

  runApp(ProviderScope(child: Boorusphere()));
}
