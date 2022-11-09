import 'package:flutter/services.dart';

class ChangelogLocalSource {
  ChangelogLocalSource(this.bundle);

  final AssetBundle bundle;

  Future<String> load() async {
    return await bundle.loadString(fileName);
  }

  static const fileName = 'CHANGELOG.md';
}
