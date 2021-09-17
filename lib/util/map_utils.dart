mixin MapUtils {
  static MapEntry<String, dynamic> findEntry(
      Map<String, dynamic> data, String key) {
    return data.entries.firstWhere(
      (e) => e.key.contains(RegExp(key)),
      orElse: () => const MapEntry('', null),
    );
  }

  static String? getUrl(Map<String, dynamic> data, String key) {
    final result = findEntry(data, key).value;
    if (result is String && result.contains(RegExp('https?:\/\/.*'))) {
      return result;
    } else {
      return null;
    }
  }

  static int getInt(Map<String, dynamic> data, String key) {
    final result = findEntry(data, key);
    if (result.value is int) {
      return result.value;
    } else if (result.value is String) {
      return int.parse(result.value);
    } else {
      return 0;
    }
  }
}
