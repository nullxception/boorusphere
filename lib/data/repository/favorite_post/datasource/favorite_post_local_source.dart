import 'dart:convert';

import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/favorite_post/entity/favorite_post.dart';
import 'package:boorusphere/presentation/provider/data_backup/data_backup.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavoritePostLocalSource {
  FavoritePostLocalSource(this.box);

  final Box<FavoritePost> box;

  Iterable<Post> get() {
    return box.values.map((e) => e.post);
  }

  Future<void> clear() async {
    await box.clear();
  }

  Future<void> delete(Post post) async {
    final fav = FavoritePost(post: post);
    await box.delete(fav.key);
  }

  Future<void> save(Post post) async {
    final fav = FavoritePost(
      post: post,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await box.put(fav.key, fav);
  }

  Future<void> import(String src) async {
    final List maps = jsonDecode(src);
    if (maps.isEmpty) return;
    await box.deleteAll(box.keys);
    for (final map in maps) {
      if (map is Map) {
        final fav = FavoritePost.fromJson(Map.from(map));
        await box.put(fav.key, fav);
      }
    }
  }

  Future<BackupItem> export() async {
    return BackupItem(key, box.values.map((e) => e.toJson()).toList());
  }

  static const String key = 'favorites';
  static Future<void> prepare() => Hive.openBox<FavoritePost>(key);
}
