import 'dart:collection';
import 'dart:convert';

import 'string.dart';

extension LinkedHashMapExt on LinkedHashMap {
  String toGDataString() {
    try {
      return jsonDecode(jsonEncode(this))['\$t'];
    } catch (e) {
      return '';
    }
  }
}

extension MapStringExt on Map<String, dynamic> {
  T take<T>(List<String> listOfKey, {required T orElse}) {
    try {
      final tKey = listOfKey.where(containsKey).first;
      final data = this[tKey];
      if (data is LinkedHashMap) {
        final g = data.toGDataString().trim();
        if (orElse is int) {
          return int.parse(g) as T;
        } else if (orElse is List) {
          return g.toWordList() as T;
        }
        return g as T;
      }

      if (orElse is int && data is! int) {
        return int.parse(data) as T;
      } else if (orElse is List && data is String) {
        return data.toWordList() as T;
      }
      return data as T;
    } catch (e) {
      return orElse;
    }
  }
}
