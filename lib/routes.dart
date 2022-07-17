import 'package:flutter/material.dart';

import 'views/containers/downloads.dart';
import 'views/containers/home.dart';
import 'views/containers/licenses.dart';
import 'views/containers/post.dart';
import 'views/containers/server.dart';
import 'views/containers/settings.dart';
import 'views/containers/tags_blocker.dart';

mixin Routes {
  static const home = '';
  static const post = 'post';
  static const tagsBlocker = 'tagsBlocker';
  static const settings = 'settings';
  static const server = 'server';
  static const licenses = 'licenses';
  static const downloads = 'downloads';

  static Map<String, WidgetBuilder> of(BuildContext context) => {
        home: (context) => const HomePage(),
        post: (context) => const PostPage(),
        tagsBlocker: (context) => const TagsBlockerPage(),
        settings: (context) => const SettingsPage(),
        licenses: (context) => const LicensesPage(),
        server: (context) => const ServerPage(),
        downloads: (context) => const DownloadsPage(),
      };
}
