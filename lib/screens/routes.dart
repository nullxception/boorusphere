import 'package:flutter/material.dart';

import 'about/about.dart';
import 'about/licenses.dart';
import 'downloads/downloads.dart';
import 'home/home.dart';
import 'post/post.dart';
import 'server/server.dart';
import 'settings/settings.dart';
import 'tags_blocker/tags_blocker.dart';

enum Routes {
  home,
  post,
  tagsBlocker,
  settings,
  server,
  licenses,
  downloads,
  about,
  changelog;

  static String initialPage = Routes.home.name;

  static Map<String, WidgetBuilder> builder(BuildContext context) => {
        home.name: (context) => const HomePage(),
        post.name: (context) => const PostPage(),
        tagsBlocker.name: (context) => const TagsBlockerPage(),
        settings.name: (context) => const SettingsPage(),
        licenses.name: (context) => const LicensesPage(),
        server.name: (context) => const ServerPage(),
        downloads.name: (context) => const DownloadsPage(),
        about.name: (context) => const AboutPage(),
      };
}
