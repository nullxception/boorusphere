import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html_unescape/html_unescape_small.dart';

abstract class BooruParser {
  BooruParser(this.server);

  final ServerData server;

  bool canParsePage(Response res);
  Iterable<Post> parsePage(Response res) {
    debugPrint('$runtimeType.parsePage: ${res.realUri}');
    return [];
  }

  bool canParseSuggestion(Response res);
  Iterable<String> parseSuggestion(Response res) {
    debugPrint('$runtimeType.parseSuggestion: ${res.realUri}');
    return [];
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

  String decodeTag(String str) {
    try {
      final unescaped = HtmlUnescape().convert(str);
      return Uri.decodeQueryComponent(unescaped);
    } on ArgumentError {
      return str;
    }
  }
}
