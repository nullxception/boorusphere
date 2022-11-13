import 'package:boorusphere/data/provider/dio.dart';
import 'package:boorusphere/data/repository/booru/booru_repo_impl.dart';
import 'package:boorusphere/data/repository/booru/datasource/booru_network_source.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:boorusphere/presentation/provider/settings/server/server_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final booruRepoProvider = Provider<BooruRepo>(
  (ref) => BooruRepoImpl(
    networkSource: BooruNetworkSource(ref.watch(dioProvider)),
    server: ref.watch(ServerSettingsProvider.active),
  ),
);
