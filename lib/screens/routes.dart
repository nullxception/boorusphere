import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../entity/server_data.dart';
import 'about/about.dart';
import 'about/licenses.dart';
import 'downloads/downloads.dart';
import 'home/home.dart';
import 'server/server.dart';
import 'server/server_edit.dart';
import 'settings/settings.dart';
import 'tags_blocker/tags_blocker.dart';

final routeProvider = Provider((ref) {
  return GoRouter(routes: [
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
              name: 'licenses',
              path: 'licenses',
              builder: (context, state) => const LicensesPage(),
            ),
          ],
        ),
      ],
    ),
  ]);
});
