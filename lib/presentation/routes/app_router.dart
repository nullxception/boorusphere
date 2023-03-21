import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/presentation/routes/app_router.gr.dart';
import 'package:boorusphere/presentation/routes/slide_page_route.dart';

@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  final List<AutoRoute> routes = [
    CustomRoute(
      page: HomeRoute.page,
      path: '/',
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: PostDetailsRoute.page,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: DownloadsRoute.page,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: ServerEditorRoute.page,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: ServerRoute.page,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: ServerPresetRoute.page,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: TagsBlockerRoute.page,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: SettingsRoute.page,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: LanguageSettingsRoute.page,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: DataBackupRoute.page,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: AboutRoute.page,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: ChangelogRoute.page,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: LicensesRoute.page,
      customRouteBuilder: SlidePageRoute.build,
    ),
    CustomRoute(
      page: FavoritesRoute.page,
      customRouteBuilder: SlidePageRoute.build,
    ),
  ];
}
