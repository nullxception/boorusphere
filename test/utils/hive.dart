import 'dart:io';

import 'package:boorusphere/data/repository/blocked_tags/entity/booru_tag.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
import 'package:boorusphere/data/repository/favorite_post/entity/favorite_post.dart';
import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/presentation/provider/settings/entity/booru_rating.dart';
import 'package:boorusphere/presentation/provider/settings/entity/download_quality.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;

void initializeTestHive() {
  final runtimeDir =
      path.join(Directory.current.path, 'build', 'test', 'runtime');
  Hive.init(runtimeDir);
  Hive
    ..registerAdapter(ServersAdapter())
    ..registerAdapter(BooruTagAdapter())
    ..registerAdapter(SearchHistoryAdapter())
    ..registerAdapter(PostAdapter())
    ..registerAdapter(DownloadEntryAdapter())
    ..registerAdapter(FavoritePostAdapter())
    ..registerAdapter(BooruRatingAdapter())
    ..registerAdapter(DownloadQualityAdapter());
}

Future<void> destroyTestHive() async {
  await Hive.deleteFromDisk();
  await Hive.close();
}
