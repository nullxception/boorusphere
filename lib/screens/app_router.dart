import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../entity/post.dart';
import '../entity/server_data.dart';
import '../source/changelog.dart';
import 'about/about.dart';
import 'about/changelog.dart';
import 'about/licenses.dart';
import 'downloads/downloads.dart';
import 'home/home.dart';
import 'post/post.dart';
import 'post/post_detail.dart';
import 'server/server.dart';
import 'server/server_edit.dart';
import 'server/server_payloads.dart';
import 'settings/settings.dart';
import 'tags_blocker/tags_blocker.dart';

part 'app_router.gr.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: [
    AutoRoute(page: HomePage, initial: true),
    CustomRoute(page: PostPage, customRouteBuilder: ChillPageRoute.build),
    AutoRoute(page: PostDetailsPage),
    AutoRoute(page: DownloadsPage),
    AutoRoute(page: ServerEditorPage),
    AutoRoute(page: ServerPage),
    AutoRoute(page: ServerPayloadsPage),
    AutoRoute(page: TagsBlockerPage),
    AutoRoute(page: SettingsPage),
    AutoRoute(page: AboutPage),
    AutoRoute(page: ChangelogPage),
    AutoRoute(page: LicensesPage),
  ],
)
class AppRouter extends _$AppRouter {}

class ChillPageRoute<T> extends MaterialPageRoute<T> {
  ChillPageRoute({
    required super.builder,
    super.settings,
    this.duration = const Duration(milliseconds: 400),
  });

  final Duration duration;

  @override
  Duration get transitionDuration => duration;

  @override
  Duration get reverseTransitionDuration => duration;

  static MaterialPageRoute<T> build<T>(
    BuildContext context,
    Widget child,
    CustomPage<T> page,
  ) {
    return ChillPageRoute(settings: page, builder: (context) => child);
  }
}
