import 'package:boorusphere/data/provider/dio.dart';
import 'package:boorusphere/data/repository/booru/booru_repo_impl.dart';
import 'package:boorusphere/data/repository/booru/datasource/booru_network_source.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final booruRepoProvider = Provider.family<BooruRepo, ServerData>(
  (ref, server) => BooruRepoImpl(
    networkSource: BooruNetworkSource(ref.watch(dioProvider)),
    server: server,
  ),
);
