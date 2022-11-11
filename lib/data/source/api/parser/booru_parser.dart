import 'package:boorusphere/data/entity/post.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class BooruParser {
  BooruParser(this.server);

  final ServerData server;

  bool canParsePage(Response res);
  List<Post> parsePage(Response res) {
    debugPrint('$runtimeType.parsePage: ${res.realUri}');
    return [];
  }

  bool canParseSuggestion(Response res);
  Set<String> parseSuggestion(Response res) {
    debugPrint('$runtimeType.parseSuggestion: ${res.realUri}');
    return {};
  }

  String normalizeUrl(String urlString) {
    try {
      final uri = Uri.parse(urlString);
      if (uri.hasScheme && uri.hasAuthority && uri.hasAbsolutePath) {
        // valid url, there's nothing to do
        return urlString;
      }

      final apiAddr = Uri.parse(server.apiAddress);
      final scheme = apiAddr.scheme == 'https' ? Uri.https : Uri.http;

      if (uri.hasAbsolutePath && !uri.hasScheme) {
        return scheme(
          !uri.hasAuthority ? apiAddr.authority : uri.authority,
          uri.path,
          uri.hasQuery ? uri.queryParametersAll : null,
        ).toString();
      }

      // nothing we can do when there's no authority and path at all
      return '';
    } catch (e) {
      return '';
    }
  }
}
