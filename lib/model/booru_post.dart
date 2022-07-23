import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import '../util/string_ext.dart';

part 'booru_post.freezed.dart';
part 'booru_post.g.dart';

enum PostType {
  video,
  photo,
  unsupported,
}

enum PostRating {
  questionable,
  explicit,
  safe;
}

@freezed
class BooruPost with _$BooruPost {
  const BooruPost._();

  @HiveType(typeId: 3, adapterName: 'BooruPostAdapter')
  const factory BooruPost({
    @HiveField(0, defaultValue: -1) required int id,
    @HiveField(1, defaultValue: '') required String originalFile,
    @HiveField(2, defaultValue: '') required String sampleFile,
    @HiveField(3, defaultValue: '') required String previewFile,
    @HiveField(4, defaultValue: []) required List<String> tags,
    @HiveField(5, defaultValue: -1) required int width,
    @HiveField(6, defaultValue: -1) required int height,
    @HiveField(7, defaultValue: '') required String serverName,
    @HiveField(8, defaultValue: '') required String postUrl,
    @HiveField(9, defaultValue: 'q') @Default('q') String rateValue,
  }) = _BooruPost;

  String get contentFile => sampleFile.isEmpty ? originalFile : sampleFile;

  PostType get contentType {
    if (contentFile.mimeType.startsWith('video')) {
      return PostType.video;
    } else if (contentFile.mimeType.startsWith('image')) {
      return PostType.photo;
    } else {
      return PostType.unsupported;
    }
  }

  PostRating get rating {
    switch (rateValue) {
      case 'explicit':
      case 'e':
        return PostRating.explicit;
      case 'safe':
      case 's':
        return PostRating.safe;
      default:
        return PostRating.questionable;
    }
  }

  static const empty = BooruPost(
    id: -1,
    originalFile: '',
    sampleFile: '',
    previewFile: '',
    tags: [],
    width: -1,
    height: -1,
    serverName: '',
    postUrl: '',
  );
}
