import 'package:boorusphere/utils/extensions/string.dart';

class ServerURLUtil {
  static (String, Map<String, String>) getClientOption(String query) {
    try {
      final uri = Uri.parse(query);
      return (
        Uri.decodeFull('${uri.removeFragment()}'),
        Uri.splitQueryString(uri.fragment.replaceFirst('opt?', '')),
      );
    } catch (e) {
      return (query, {});
    }
  }

  static (String, Map<String, String>) constructHeaders(String url) {
    final (realUrl, clientOption) = getClientOption(url);
    final headers = <String, String>{};
    final queryPart = Uri.splitQueryString(realUrl.toUri().query);
    if (queryPart['json'] == '1' || clientOption['json'] == '1') {
      headers['Accept'] = 'application/json';
      headers['Content-type'] = 'application/json';
    }
    return (realUrl, headers);
  }
}
