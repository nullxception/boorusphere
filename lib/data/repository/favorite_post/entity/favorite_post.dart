import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'favorite_post.freezed.dart';
part 'favorite_post.g.dart';

@freezed
class FavoritePost with _$FavoritePost {
  @HiveType(typeId: 5, adapterName: 'FavoritePostAdapter')
  const factory FavoritePost({
    @HiveField(0, defaultValue: Post.empty) @Default(Post.empty) Post post,
    @HiveField(1, defaultValue: 0) @Default(0) int timestamp,
  }) = _FavoritePost;
  const FavoritePost._();

  factory FavoritePost.fromJson(Map<String, dynamic> json) =>
      _$FavoritePostFromJson(json);

  String get key => '${post.id}@${post.serverId}';
}
