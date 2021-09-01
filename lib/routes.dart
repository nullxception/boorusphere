import 'package:flutter/material.dart';

import 'views/containers/home.dart';
import 'views/containers/licenses.dart';
import 'views/containers/post.dart';
import 'views/containers/settings.dart';
import 'views/containers/tags_blocker.dart';

mixin Routes {
  static const home = '';
  static const post = 'post';
  static const tagsBlocker = 'tagsBlocker';
  static const settings = 'settings';
  static const licenses = 'licenses';

  static Map<String, WidgetBuilder> of(BuildContext context) => {
        home: (context) => Home(),
        post: (context) => Post(),
        tagsBlocker: (context) => TagsBlocker(),
        settings: (context) => Settings(),
        licenses: (context) => Licenses(),
      };
}
