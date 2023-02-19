import 'package:hive/hive.dart';

part 'search_rating.g.dart';

@HiveType(typeId: 7, adapterName: 'SearchRatingAdapter')
enum SearchRating {
  @HiveField(0)
  all,
  @HiveField(1)
  questionable,
  @HiveField(2)
  explicit,
  @HiveField(3)
  safe;
}
