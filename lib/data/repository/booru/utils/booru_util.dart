import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:path/path.dart' as path;

class BooruUtil {
  static String normalizeUrl(ServerData server, String urlString) {
    if (urlString.isEmpty) {
      // wtf are you doing here
      return '';
    }
    try {
      final uri = Uri.parse(urlString);
      if (uri.hasScheme && uri.hasAuthority && uri.hasAbsolutePath) {
        // valid url, there's nothing to do
        return urlString;
      }

      final apiAddr = Uri.parse(server.apiAddress);
      final scheme = apiAddr.scheme == 'https' ? Uri.https : Uri.http;

      if (!uri.hasScheme) {
        final cpath = path.Context(style: path.Style.url);
        final newAuth = uri.hasAuthority ? uri.authority : apiAddr.authority;
        final newPath = cpath.join(apiAddr.path, uri.path);
        final newQuery = uri.hasQuery ? uri.queryParametersAll : null;
        final newUri = scheme(newAuth, newPath, newQuery);
        return newUri.toString();
      }

      // nothing we can do when there's no authority and path at all
      return '';
    } catch (e) {
      return '';
    }
  }

  static String decodeTag(String str) {
    try {
      final unescaped = HtmlUnescape().convert(str);
      return Uri.decodeQueryComponent(unescaped);
    } on ArgumentError {
      return str;
    }
  }
}
