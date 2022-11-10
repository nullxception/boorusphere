import 'package:boorusphere/data/repository/favorite_post/datasource/favorite_post_local_source.dart';
import 'package:boorusphere/data/repository/favorite_post/favorite_post_repo_impl.dart';
import 'package:boorusphere/domain/repository/favorite_post_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final favoritePostRepoProvider = Provider<FavoritePostRepo>(
  (ref) => FavoritePostRepoImpl(
    localSource: FavoritePostLocalSource(Hive.box(FavoritePostLocalSource.key)),
  ),
);
