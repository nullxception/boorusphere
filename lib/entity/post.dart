import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../utils/extensions/string.dart';
import 'pixel_size.dart';

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

@HiveType(typeId: 3, adapterName: 'PostAdapter')
class Post {
  const Post({
    this.id = -1,
    this.originalFile = '',
    this.sampleFile = '',
    this.previewFile = '',
    this.tags = const [],
    this.width = -1,
    this.height = -1,
    this.serverName = '',
    this.postUrl = '',
    this.rateValue = 'q',
    this.sampleWidth = -1,
    this.sampleHeight = -1,
    this.previewWidth = -1,
    this.previewHeight = -1,
    this.source = '',
    this.tagsArtist = const [],
    this.tagsCharacter = const [],
    this.tagsCopyright = const [],
    this.tagsGeneral = const [],
    this.tagsMeta = const [],
  });

  @HiveField(0, defaultValue: -1)
  final int id;
  @HiveField(1, defaultValue: '')
  final String originalFile;
  @HiveField(2, defaultValue: '')
  final String sampleFile;
  @HiveField(3, defaultValue: '')
  final String previewFile;
  @HiveField(4, defaultValue: [])
  final List<String> tags;
  @HiveField(5, defaultValue: -1)
  final int width;
  @HiveField(6, defaultValue: -1)
  final int height;
  @HiveField(7, defaultValue: '')
  final String serverName;
  @HiveField(8, defaultValue: '')
  final String postUrl;
  @HiveField(9, defaultValue: 'q')
  final String rateValue;
  @HiveField(10, defaultValue: -1)
  final int sampleWidth;
  @HiveField(11, defaultValue: -1)
  final int sampleHeight;
  @HiveField(12, defaultValue: -1)
  final int previewWidth;
  @HiveField(13, defaultValue: -1)
  final int previewHeight;
  @HiveField(14, defaultValue: '')
  final String source;
  @HiveField(15, defaultValue: [])
  final List<String> tagsArtist;
  @HiveField(16, defaultValue: [])
  final List<String> tagsCharacter;
  @HiveField(17, defaultValue: [])
  final List<String> tagsCopyright;
  @HiveField(18, defaultValue: [])
  final List<String> tagsGeneral;
  @HiveField(19, defaultValue: [])
  final List<String> tagsMeta;

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

  @override
  bool operator ==(covariant Post other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.originalFile == originalFile &&
        other.sampleFile == sampleFile &&
        other.previewFile == previewFile &&
        listEquals(other.tags, tags) &&
        other.width == width &&
        other.height == height &&
        other.serverName == serverName &&
        other.postUrl == postUrl &&
        other.rateValue == rateValue &&
        other.sampleWidth == sampleWidth &&
        other.sampleHeight == sampleHeight &&
        other.previewWidth == previewWidth &&
        other.previewHeight == previewHeight &&
        other.source == source &&
        listEquals(other.tagsArtist, tagsArtist) &&
        listEquals(other.tagsCharacter, tagsCharacter) &&
        listEquals(other.tagsCopyright, tagsCopyright) &&
        listEquals(other.tagsGeneral, tagsGeneral) &&
        listEquals(other.tagsMeta, tagsMeta);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        originalFile.hashCode ^
        sampleFile.hashCode ^
        previewFile.hashCode ^
        tags.hashCode ^
        width.hashCode ^
        height.hashCode ^
        serverName.hashCode ^
        postUrl.hashCode ^
        rateValue.hashCode ^
        sampleWidth.hashCode ^
        sampleHeight.hashCode ^
        previewWidth.hashCode ^
        previewHeight.hashCode ^
        source.hashCode ^
        tagsArtist.hashCode ^
        tagsCharacter.hashCode ^
        tagsCopyright.hashCode ^
        tagsGeneral.hashCode ^
        tagsMeta.hashCode;
  }

  Post copyWith({
    int? id,
    String? originalFile,
    String? sampleFile,
    String? previewFile,
    List<String>? tags,
    int? width,
    int? height,
    String? serverName,
    String? postUrl,
    String? rateValue,
    int? sampleWidth,
    int? sampleHeight,
    int? previewWidth,
    int? previewHeight,
    String? source,
    List<String>? tagsArtist,
    List<String>? tagsCharacter,
    List<String>? tagsCopyright,
    List<String>? tagsGeneral,
    List<String>? tagsMeta,
  }) {
    return Post(
      id: id ?? this.id,
      originalFile: originalFile ?? this.originalFile,
      sampleFile: sampleFile ?? this.sampleFile,
      previewFile: previewFile ?? this.previewFile,
      tags: tags ?? this.tags,
      width: width ?? this.width,
      height: height ?? this.height,
      serverName: serverName ?? this.serverName,
      postUrl: postUrl ?? this.postUrl,
      rateValue: rateValue ?? this.rateValue,
      sampleWidth: sampleWidth ?? this.sampleWidth,
      sampleHeight: sampleHeight ?? this.sampleHeight,
      previewWidth: previewWidth ?? this.previewWidth,
      previewHeight: previewHeight ?? this.previewHeight,
      source: source ?? this.source,
      tagsArtist: tagsArtist ?? this.tagsArtist,
      tagsCharacter: tagsCharacter ?? this.tagsCharacter,
      tagsCopyright: tagsCopyright ?? this.tagsCopyright,
      tagsGeneral: tagsGeneral ?? this.tagsGeneral,
      tagsMeta: tagsMeta ?? this.tagsMeta,
    );
  }

  static const empty = Post();
}
