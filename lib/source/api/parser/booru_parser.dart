import 'package:dio/dio.dart';

import '../../../entity/post.dart';
import '../../../entity/server_data.dart';

abstract class BooruParser {
  BooruParser(this.server);

  final ServerData server;

  List<Post> parsePage(Response res);
  bool canParsePage(Response res);

  Set<String> parseSuggestion(Response res);
  bool canParseSuggestion(Response res);

  String normalizeUrl(String urlString) {
    try {
      final uri = Uri.parse(urlString);
      if (uri.hasScheme && uri.hasAuthority && uri.hasAbsolutePath) {
        // valid url, there's nothing to do
        return urlString;
      }

      if (uri.hasAuthority && uri.hasAbsolutePath && !uri.hasScheme) {
        final origin = Uri.parse(server.apiAddress);
        final scheme = origin.scheme == 'https' ? Uri.https : Uri.http;
        return scheme(uri.authority, uri.path,
                uri.hasQuery ? uri.queryParametersAll : null)
            .toString();
      }

      // nothing we can do when there's no authority and path
      return '';
    } catch (e) {
      return '';
    }
  }
}
