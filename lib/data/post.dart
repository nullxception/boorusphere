import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import '../utils/string_ext.dart';
import 'pixel_size.dart';

part 'post.freezed.dart';
part 'post.g.dart';

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
class Post with _$Post {
  const Post._();

  @HiveType(typeId: 3, adapterName: 'PostAdapter')
  const factory Post({
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
    @HiveField(10, defaultValue: -1) @Default(-1) int sampleWidth,
    @HiveField(11, defaultValue: -1) @Default(-1) int sampleHeight,
    @HiveField(12, defaultValue: -1) @Default(-1) int previewWidth,
    @HiveField(13, defaultValue: -1) @Default(-1) int previewHeight,
    @HiveField(14, defaultValue: '') @Default('') String source,
  }) = _Post;

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

  PixelSize get originalSize => PixelSize(width: width, height: height);

  PixelSize get sampleSize =>
      PixelSize(width: sampleWidth, height: sampleHeight);

  PixelSize get previewSize =>
      PixelSize(width: previewWidth, height: previewHeight);

  double get aspectRatio {
    if (previewSize.hasPixels) {
      return previewSize.aspectRatio;
    } else if (sampleSize.hasPixels) {
      return sampleSize.aspectRatio;
    } else {
      return originalSize.aspectRatio;
    }
  }

  static const empty = Post(
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
