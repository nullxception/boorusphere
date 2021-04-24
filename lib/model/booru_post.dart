import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';

part 'booru_post.freezed.dart';

enum PostType {
  video,
  photo,
  unsupported,
}

@freezed
class BooruPost with _$BooruPost {
  const BooruPost._();

  const factory BooruPost({
    required int id,
    required String src,
    required String displaySrc,
    required String thumbnail,
    required List<String> tags,
    required int width,
    required int height,
  }) = _BooruPost;

  factory BooruPost.empty() => const BooruPost(
        id: -1,
        src: '',
        displaySrc: '',
        thumbnail: '',
        tags: [],
        width: -1,
        height: -1,
      );

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
}
