import 'package:flutter/material.dart';

import 'about/about.dart';
import 'about/licenses.dart';
import 'downloads/downloads.dart';
import 'home/home.dart';
import 'post/post.dart';
import 'server/server.dart';
import 'settings/settings.dart';
import 'tags_blocker/tags_blocker.dart';

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
