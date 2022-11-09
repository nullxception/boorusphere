import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/entity/post.dart';
import 'package:boorusphere/entity/server_data.dart';
import 'package:boorusphere/routes/chill_page.dart';
import 'package:boorusphere/routes/slide_page.dart';
import 'package:boorusphere/screens/about/about.dart';
import 'package:boorusphere/screens/about/changelog.dart';
import 'package:boorusphere/screens/about/licenses.dart';
import 'package:boorusphere/screens/downloads/downloads.dart';
import 'package:boorusphere/screens/favorites/favorites.dart';
import 'package:boorusphere/screens/home/home.dart';
import 'package:boorusphere/screens/home/timeline/controller.dart';
import 'package:boorusphere/screens/post/post.dart';
import 'package:boorusphere/screens/post/post_detail.dart';
import 'package:boorusphere/screens/server/server.dart';
import 'package:boorusphere/screens/server/server_edit.dart';
import 'package:boorusphere/screens/server/server_payloads.dart';
import 'package:boorusphere/screens/settings/settings.dart';
import 'package:boorusphere/screens/tags_blocker/tags_blocker.dart';
import 'package:boorusphere/source/changelog.dart';
import 'package:flutter/material.dart';

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
    CustomRoute(
      page: FavoritesPage,
      customRouteBuilder: SlidePageRoute.build,
    ),
  ],
)
class SphereRouter extends _$SphereRouter {}
