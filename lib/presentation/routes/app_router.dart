import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/presentation/provider/changelog_state.dart';
import 'package:boorusphere/presentation/routes/chill_page_route.dart';
import 'package:boorusphere/presentation/routes/slide_page_route.dart';
import 'package:boorusphere/presentation/screens/about/about_page.dart';
import 'package:boorusphere/presentation/screens/about/changelog_page.dart';
import 'package:boorusphere/presentation/screens/about/licenses_page.dart';
import 'package:boorusphere/presentation/screens/downloads/downloads_page.dart';
import 'package:boorusphere/presentation/screens/favorites/favorites_page.dart';
import 'package:boorusphere/presentation/screens/home/home_page.dart';
import 'package:boorusphere/presentation/screens/home/page_args.dart';
import 'package:boorusphere/presentation/screens/post/post_details_page.dart';
import 'package:boorusphere/presentation/screens/post/post_page.dart';
import 'package:boorusphere/presentation/screens/server/server_editor_page.dart';
import 'package:boorusphere/presentation/screens/server/server_page.dart';
import 'package:boorusphere/presentation/screens/server/server_preset_page.dart';
import 'package:boorusphere/presentation/screens/settings/data_backup_page.dart';
import 'package:boorusphere/presentation/screens/settings/language_settings_page.dart';
import 'package:boorusphere/presentation/screens/settings/settings_page.dart';
import 'package:boorusphere/presentation/screens/tags_blocker/tags_blocker_page.dart';
import 'package:boorusphere/presentation/widgets/timeline/timeline_controller.dart';
import 'package:flutter/widgets.dart';

part 'app_router.gr.dart';

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
      page: ServerPresetPage,
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
      page: LanguageSettingsPage,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: DataBackupPage,
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
class AppRouter extends _$AppRouter {}
