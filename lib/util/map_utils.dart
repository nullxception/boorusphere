import 'dart:collection';
import 'dart:convert';

mixin MapUtils {
  static MapEntry<String, dynamic> findEntry(
      Map<String, dynamic> data, String key) {
    return data.entries.firstWhere(
      (e) => e.key.contains(RegExp(key)),
      orElse: () => const MapEntry('', null),
    );
  }

  static String getGdataText(dynamic data) {
    try {
      return jsonDecode(jsonEncode(data))['\$t'];
    } catch (e) {
      return '';
    }
  }

  static String getUrl(Map<String, dynamic> data, String key) {
    if (data.values.first is LinkedHashMap) {
      final gdata = data.entries.firstWhere(
          (e) =>
              e.value.toString().contains('http') &&
              e.key.contains(RegExp(key)),
          orElse: () => const MapEntry('', ''));
      return getGdataText(gdata.value);
    }

    return data.entries
        .firstWhere((e) => e.value is String && e.key.contains(RegExp(key)),
            orElse: () => const MapEntry('', ''))
        .value;
  }

  static int getInt(Map<String, dynamic> data, String key, {int or = 0}) {
    final res = findEntry(data, key).value;
    if (res is int) {
      return res;
    } else if (res is String) {
      return int.parse(res);
    } else if (res is LinkedHashMap) {
      return int.parse(getGdataText(res));
    }

    return or;
  }

  static List<String> getWordlist(Map<String, dynamic> data, String key) {
    final res = findEntry(data, key).value;
    if (res is LinkedHashMap) {
      return getGdataText(res).trim().split(' ');
    } else if (res is List) {
      return res.toString().trim().split(' ');
    } else if (res is String) {
      return res.trim().split(' ');
    }

    return [];
  }

  static String getString(Map<String, dynamic> data, String key) {
    final res = findEntry(data, key).value;
    if (res is LinkedHashMap) {
      return getGdataText(res).trim();
    } else if (res is String) {
      return res.trim();
    }

    return '';
  }
}
