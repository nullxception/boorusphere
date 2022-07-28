import 'package:flutter/material.dart';

import 'screens/about.dart';
import 'screens/downloads.dart';
import 'screens/home.dart';
import 'screens/licenses.dart';
import 'screens/post.dart';
import 'screens/server.dart';
import 'screens/settings.dart';
import 'screens/tags_blocker.dart';

mixin Routes {
  static const home = '';
  static const post = 'post';
  static const tagsBlocker = 'tagsBlocker';
  static const settings = 'settings';
  static const server = 'server';
  static const licenses = 'licenses';
  static const downloads = 'downloads';

  static const about = 'about';

  static Map<String, WidgetBuilder> of(BuildContext context) => {
        home: (context) => const HomePage(),
        post: (context) => const PostPage(),
        tagsBlocker: (context) => const TagsBlockerPage(),
        settings: (context) => const SettingsPage(),
        licenses: (context) => const LicensesPage(),
        server: (context) => const ServerPage(),
        downloads: (context) => const DownloadsPage(),
        about: (context) => const AboutPage(),
      };
}
