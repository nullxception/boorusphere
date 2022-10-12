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
  T tryGet<T>(String keyName, {required T orElse}) {
    try {
      final data = this[keyName];
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

  Map<String, dynamic> tryMap(String keyName) {
    try {
      return this[keyName] as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  List<T> tryList<T>(String keyName) {
    try {
      return List<T>.from(this[keyName]);
    } catch (e) {
      return [];
    }
  }
}
