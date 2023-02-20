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
  @HiveField(3)
  explicit;

  String getString(BuildContext context) {
    switch (this) {
      case BooruRating.safe:
        return context.t.rating.safe;
      case BooruRating.questionable:
        return context.t.rating.questionable;
      case BooruRating.explicit:
        return context.t.rating.explicit;
      default:
        return context.t.rating.all;
    }
  }
}
