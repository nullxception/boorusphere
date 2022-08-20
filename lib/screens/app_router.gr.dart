// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

part of 'app_router.dart';

class _$AppRouter extends RootStackRouter {
  _$AppRouter([GlobalKey<NavigatorState>? navigatorKey]) : super(navigatorKey);

  @override
  final Map<String, PageFactory> pagesMap = {
    HomeRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: const HomePage());
    },
    PostRoute.name: (routeData) {
      final args = routeData.argsAs<PostRouteArgs>();
      return CustomPage<dynamic>(
          routeData: routeData,
          child: PostPage(
              key: args.key,
              beginPage: args.beginPage,
              onReturned: args.onReturned),
          customRouteBuilder: ChillPageRoute.build,
          opaque: true,
          barrierDismissible: false);
    },
    PostDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<PostDetailsRouteArgs>();
      return MaterialPageX<dynamic>(
          routeData: routeData,
          child: PostDetailsPage(key: args.key, post: args.post));
    },
    DownloadsRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: const DownloadsPage());
    },
    ServerEditorRoute.name: (routeData) {
      final args = routeData.argsAs<ServerEditorRouteArgs>(
          orElse: () => const ServerEditorRouteArgs());
      return MaterialPageX<dynamic>(
          routeData: routeData,
          child: ServerEditorPage(key: args.key, server: args.server));
    },
    ServerRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: const ServerPage());
    },
    ServerPayloadsRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: const ServerPayloadsPage());
    },
    TagsBlockerRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: const TagsBlockerPage());
    },
    SettingsRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: const SettingsPage());
    },
    AboutRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: const AboutPage());
    },
    ChangelogRoute.name: (routeData) {
      final args = routeData.argsAs<ChangelogRouteArgs>();
      return MaterialPageX<dynamic>(
          routeData: routeData,
          child: ChangelogPage(key: args.key, option: args.option));
    },
    LicensesRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: const LicensesPage());
    }
  };

  @override
  List<RouteConfig> get routes => [
        RouteConfig(HomeRoute.name, path: '/'),
        RouteConfig(PostRoute.name, path: '/post-page'),
        RouteConfig(PostDetailsRoute.name, path: '/post-details-page'),
        RouteConfig(DownloadsRoute.name, path: '/downloads-page'),
        RouteConfig(ServerEditorRoute.name, path: '/server-editor-page'),
        RouteConfig(ServerRoute.name, path: '/server-page'),
        RouteConfig(ServerPayloadsRoute.name, path: '/server-payloads-page'),
        RouteConfig(TagsBlockerRoute.name, path: '/tags-blocker-page'),
        RouteConfig(SettingsRoute.name, path: '/settings-page'),
        RouteConfig(AboutRoute.name, path: '/about-page'),
        RouteConfig(ChangelogRoute.name, path: '/changelog-page'),
        RouteConfig(LicensesRoute.name, path: '/licenses-page')
      ];
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute() : super(HomeRoute.name, path: '/');

  static const String name = 'HomeRoute';
}

/// generated route for
/// [PostPage]
class PostRoute extends PageRouteInfo<PostRouteArgs> {
  PostRoute({Key? key, required int beginPage, void Function(int)? onReturned})
      : super(PostRoute.name,
            path: '/post-page',
            args: PostRouteArgs(
                key: key, beginPage: beginPage, onReturned: onReturned));

  static const String name = 'PostRoute';
}

class PostRouteArgs {
  const PostRouteArgs({this.key, required this.beginPage, this.onReturned});

  final Key? key;

  final int beginPage;

  final void Function(int)? onReturned;

  @override
  String toString() {
    return 'PostRouteArgs{key: $key, beginPage: $beginPage, onReturned: $onReturned}';
  }
}

/// generated route for
/// [PostDetailsPage]
class PostDetailsRoute extends PageRouteInfo<PostDetailsRouteArgs> {
  PostDetailsRoute({Key? key, required Post post})
      : super(PostDetailsRoute.name,
            path: '/post-details-page',
            args: PostDetailsRouteArgs(key: key, post: post));

  static const String name = 'PostDetailsRoute';
}

class PostDetailsRouteArgs {
  const PostDetailsRouteArgs({this.key, required this.post});

  final Key? key;

  final Post post;

  @override
  String toString() {
    return 'PostDetailsRouteArgs{key: $key, post: $post}';
  }
}

/// generated route for
/// [DownloadsPage]
class DownloadsRoute extends PageRouteInfo<void> {
  const DownloadsRoute() : super(DownloadsRoute.name, path: '/downloads-page');

  static const String name = 'DownloadsRoute';
}

/// generated route for
/// [ServerEditorPage]
class ServerEditorRoute extends PageRouteInfo<ServerEditorRouteArgs> {
  ServerEditorRoute({Key? key, ServerData server = ServerData.empty})
      : super(ServerEditorRoute.name,
            path: '/server-editor-page',
            args: ServerEditorRouteArgs(key: key, server: server));

  static const String name = 'ServerEditorRoute';
}

class ServerEditorRouteArgs {
  const ServerEditorRouteArgs({this.key, this.server = ServerData.empty});

  final Key? key;

  final ServerData server;

  @override
  String toString() {
    return 'ServerEditorRouteArgs{key: $key, server: $server}';
  }
}

/// generated route for
/// [ServerPage]
class ServerRoute extends PageRouteInfo<void> {
  const ServerRoute() : super(ServerRoute.name, path: '/server-page');

  static const String name = 'ServerRoute';
}

/// generated route for
/// [ServerPayloadsPage]
class ServerPayloadsRoute extends PageRouteInfo<void> {
  const ServerPayloadsRoute()
      : super(ServerPayloadsRoute.name, path: '/server-payloads-page');

  static const String name = 'ServerPayloadsRoute';
}

/// generated route for
/// [TagsBlockerPage]
class TagsBlockerRoute extends PageRouteInfo<void> {
  const TagsBlockerRoute()
      : super(TagsBlockerRoute.name, path: '/tags-blocker-page');

  static const String name = 'TagsBlockerRoute';
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute() : super(SettingsRoute.name, path: '/settings-page');

  static const String name = 'SettingsRoute';
}

/// generated route for
/// [AboutPage]
class AboutRoute extends PageRouteInfo<void> {
  const AboutRoute() : super(AboutRoute.name, path: '/about-page');

  static const String name = 'AboutRoute';
}

/// generated route for
/// [ChangelogPage]
class ChangelogRoute extends PageRouteInfo<ChangelogRouteArgs> {
  ChangelogRoute({Key? key, required ChangelogOption option})
      : super(ChangelogRoute.name,
            path: '/changelog-page',
            args: ChangelogRouteArgs(key: key, option: option));

  static const String name = 'ChangelogRoute';
}

class ChangelogRouteArgs {
  const ChangelogRouteArgs({this.key, required this.option});

  final Key? key;

  final ChangelogOption option;

  @override
  String toString() {
    return 'ChangelogRouteArgs{key: $key, option: $option}';
  }
}

/// generated route for
/// [LicensesPage]
class LicensesRoute extends PageRouteInfo<void> {
  const LicensesRoute() : super(LicensesRoute.name, path: '/licenses-page');

  static const String name = 'LicensesRoute';
}
