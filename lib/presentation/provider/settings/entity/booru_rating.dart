import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'booru_rating.g.dart';

@HiveType(typeId: 7, adapterName: 'BooruRatingAdapter')
enum BooruRating {
  @HiveField(0)
  all,
  @HiveField(1)
  safe,
  @HiveField(2)
  questionable,
  @HiveField(4)
  sensitive,
  @HiveField(3)
  explicit;

  String describe(BuildContext context) {
    switch (this) {
      case BooruRating.safe:
        return context.t.rating.safe;
      case BooruRating.questionable:
        return context.t.rating.questionable;
      case BooruRating.explicit:
        return context.t.rating.explicit;
      case BooruRating.sensitive:
        return context.t.rating.sensitive;
      default:
        return '';
    }
  }

  bool get isExplicit => this == BooruRating.explicit;

  static BooruRating parse(String metadata) {
    switch (metadata) {
      case 'sensitive':
        return BooruRating.sensitive;
      case 'explicit':
      case 'e':
        return BooruRating.explicit;
      case 'safe':
      case 's':
        return BooruRating.safe;
      default:
        return BooruRating.questionable;
    }
  }

  static BooruRating fromName(String name) {
    return BooruRating.values
        .firstWhere((it) => it.name == name, orElse: () => BooruRating.safe);
  }
}
