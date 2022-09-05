import 'package:hive/hive.dart';

import 'post.dart';

part 'favorite_post.g.dart';

@HiveType(typeId: 5, adapterName: 'FavoritePostAdapter')
class FavoritePost {
  const FavoritePost({
    this.post = Post.empty,
    this.timestamp = 0,
  });

  @HiveField(0, defaultValue: Post.empty)
  final Post post;
  @HiveField(1, defaultValue: 0)
  final int timestamp;

  String get key => '${post.id}@${post.serverId}';
}
