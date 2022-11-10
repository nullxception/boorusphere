import 'package:boorusphere/data/repository/blocked_tags/blocked_tags_repo_impl.dart';
import 'package:boorusphere/data/repository/blocked_tags/datasource/blocked_tags_local_source.dart';
import 'package:boorusphere/domain/repository/blocked_tags_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final blockedTagsRepoProvider = Provider<BlockedTagsRepo>(
  (ref) => BlockedTagsRepoImpl(
    localSource: BlockedTagsLocalSource(Hive.box(BlockedTagsLocalSource.key)),
  ),
);
