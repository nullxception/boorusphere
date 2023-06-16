import 'dart:io';

import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_entry.dart';
import 'package:boorusphere/data/repository/favorite_post/entity/favorite_post.dart';
import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';
import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:boorusphere/data/repository/tags_blocker/entity/booru_tag.dart';
import 'package:boorusphere/presentation/provider/settings/entity/booru_rating.dart';
import 'package:boorusphere/presentation/provider/settings/entity/download_quality.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;

class HiveTestContainer {
  HiveTestContainer() {
    final ud = path.join(Directory.current.path, 'build', 'test_hive');
    final dir = Directory(ud)..createSync(recursive: true);
    _dir = dir.createTempSync();

    Hive.init(_dir.absolute.path);
    Hive
      ..registerAdapter(ServerAdapter())
      ..registerAdapter(BooruTagAdapter())
      ..registerAdapter(SearchHistoryAdapter())
      ..registerAdapter(PostAdapter())
      ..registerAdapter(DownloadEntryAdapter())
      ..registerAdapter(FavoritePostAdapter())
      ..registerAdapter(BooruRatingAdapter())
      ..registerAdapter(DownloadQualityAdapter());
  }

  late Directory _dir;

  Future<void> dispose() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (_dir.listSync().isEmpty) {
      _dir.deleteSync();
    }
  }
}
