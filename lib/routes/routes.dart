import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../entity/post.dart';
import '../entity/server_data.dart';
import '../screens/about/about.dart';
import '../screens/about/changelog.dart';
import '../screens/about/licenses.dart';
import '../screens/downloads/downloads.dart';
import '../screens/home/home.dart';
import '../screens/post/post.dart';
import '../screens/post/post_detail.dart';
import '../screens/server/server.dart';
import '../screens/server/server_edit.dart';
import '../screens/server/server_payloads.dart';
import '../screens/settings/settings.dart';
import '../screens/tags_blocker/tags_blocker.dart';
import '../source/changelog.dart';
import 'chill_page.dart';
import 'slide_page.dart';

part 'routes.gr.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: [
    AutoRoute(page: HomePage, initial: true),
    CustomRoute(
      page: PostPage,
      customRouteBuilder: ChillPageRoute.build,
    ),
    CustomRoute(
      page: PostDetailsPage,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: DownloadsPage,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: ServerEditorPage,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: ServerPage,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: ServerPayloadsPage,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: TagsBlockerPage,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: SettingsPage,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: AboutPage,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: ChangelogPage,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: LicensesPage,
      customRouteBuilder: SlidePageRoute.build,
    ),
  ],
)
class SphereRouter extends _$SphereRouter {}
