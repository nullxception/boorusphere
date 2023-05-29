import 'package:boorusphere/data/repository/blocked_tags/entity/booru_tag.dart';

abstract interface class BlockedTagsRepo {
  Map<int, BooruTag> get();
  Future<void> delete(key);
  Future<void> push(BooruTag value);
}
