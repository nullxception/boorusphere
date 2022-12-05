import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/utils/entity/content.dart';
import 'package:boorusphere/presentation/utils/entity/pixel_size.dart';

enum PostRating {
  questionable,
  explicit,
  safe;
}

extension PostExt on Post {
  bool get hasCategorizedTags => [
        ...tagsArtist,
        ...tagsCharacter,
        ...tagsCopyright,
        ...tagsGeneral,
        ...tagsMeta
      ].isNotEmpty;

  String get describeTags => {
        ...tagsArtist,
        ...tagsCharacter,
        ...tagsCopyright,
        ...tagsGeneral,
        ...tagsMeta,
        ...tags,
      }.join(' ');

  double get aspectRatio {
    if (prescreensize.hasPixels) {
      return prescreensize.aspectRatio;
    } else if (sampleSize.hasPixels) {
      return sampleSize.aspectRatio;
    } else {
      return originalSize.aspectRatio;
    }
  }

  PixelSize get originalSize => PixelSize(width: width, height: height);

  PixelSize get sampleSize =>
      PixelSize(width: sampleWidth, height: sampleHeight);

  PixelSize get prescreensize =>
      PixelSize(width: previewWidth, height: previewHeight);

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

  Content get content {
    final sample = sampleFile.asContent();
    final original = originalFile.asContent();
    if (sample.isPhoto && original.isVideo || sample.isUnsupported) {
      return original;
    }

    return sample;
  }
}
