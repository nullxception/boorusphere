import 'package:boorusphere/data/repository/server/datasource/server_local_source.dart';
import 'package:boorusphere/data/repository/server/server_repo_impl.dart';
import 'package:boorusphere/domain/repository/server_repo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final serverRepoProvider = Provider<ServerRepo>(
  (ref) => ServerRepoImpl(
    localSource: ServerLocalSource(
      assetBundle: rootBundle,
      box: Hive.box(ServerLocalSource.key),
    ),
  ),
);
