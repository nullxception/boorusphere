import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:mime/mime.dart';

part 'booru_post.freezed.dart';
part 'booru_post.g.dart';

enum PostType {
  video,
  photo,
  unsupported,
}

@freezed
class BooruPost with _$BooruPost {
  const BooruPost._();

  @HiveType(typeId: 3, adapterName: 'BooruPostAdapter')
  const factory BooruPost({
    @HiveField(0) required int id,
    @HiveField(1) required String src,
    @HiveField(2) required String displaySrc,
    @HiveField(3) required String thumbnail,
    @HiveField(4) required List<String> tags,
    @HiveField(5) required int width,
    @HiveField(6) required int height,
    @HiveField(7) required String serverName,
  }) = _BooruPost;

  String get mimeType =>
      lookupMimeType(src.split('/').last) ?? 'application/octet-stream';

  PostType get displayType {
    final dispMime = lookupMimeType(displaySrc.split('/').last) ?? '';
    if (dispMime.startsWith('video')) {
      return PostType.video;
    } else if (dispMime.startsWith('image')) {
      return PostType.photo;
    } else {
      return PostType.unsupported;
    }
  }

  static const empty = BooruPost(
      id: -1,
      src: '',
      displaySrc: '',
      thumbnail: '',
      tags: [],
      width: -1,
      height: -1,
      serverName: '');
}
