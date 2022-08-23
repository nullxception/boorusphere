import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import '../utils/extensions/string.dart';
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
  @HiveType(typeId: 3, adapterName: 'PostAdapter')
  const factory Post({
    @HiveField(0, defaultValue: -1) @Default(-1) int id,
    @HiveField(1, defaultValue: '') @Default('') String originalFile,
    @HiveField(2, defaultValue: '') @Default('') String sampleFile,
    @HiveField(3, defaultValue: '') @Default('') String previewFile,
    @HiveField(4, defaultValue: []) @Default([]) List<String> tags,
    @HiveField(5, defaultValue: -1) @Default(-1) int width,
    @HiveField(6, defaultValue: -1) @Default(-1) int height,
    @HiveField(7, defaultValue: '') @Default('') String serverName,
    @HiveField(8, defaultValue: '') @Default('') String postUrl,
    @HiveField(9, defaultValue: 'q') @Default('q') String rateValue,
    @HiveField(10, defaultValue: -1) @Default(-1) int sampleWidth,
    @HiveField(11, defaultValue: -1) @Default(-1) int sampleHeight,
    @HiveField(12, defaultValue: -1) @Default(-1) int previewWidth,
    @HiveField(13, defaultValue: -1) @Default(-1) int previewHeight,
    @HiveField(14, defaultValue: '') @Default('') String source,
    @HiveField(15, defaultValue: []) @Default([]) List<String> tagsArtist,
    @HiveField(16, defaultValue: []) @Default([]) List<String> tagsCharacter,
    @HiveField(17, defaultValue: []) @Default([]) List<String> tagsCopyright,
    @HiveField(18, defaultValue: []) @Default([]) List<String> tagsGeneral,
    @HiveField(19, defaultValue: []) @Default([]) List<String> tagsMeta,
  }) = _Post;
  const Post._();

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

  PixelSize get prescreensize =>
      PixelSize(width: previewWidth, height: previewHeight);

  double get aspectRatio {
    if (prescreensize.hasPixels) {
      return prescreensize.aspectRatio;
    } else if (sampleSize.hasPixels) {
      return sampleSize.aspectRatio;
    } else {
      return originalSize.aspectRatio;
    }
  }

  bool get hasCategorizedTags => [
        ...tagsArtist,
        ...tagsCharacter,
        ...tagsCopyright,
        ...tagsGeneral,
        ...tagsMeta
      ].isNotEmpty;

  static const empty = Post();
}
