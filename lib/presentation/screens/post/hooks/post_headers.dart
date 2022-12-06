import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/booru/extension/post.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

AsyncSnapshot<Map<String, String>> usePostHeaders(WidgetRef ref, Post post) {
  return useFuture(
    useMemoized(
      () => post.buildHeaders(
        cookieJar: ref.read(cookieJarProvider),
        server: ref
            .read(serverDataStateProvider)
            .getById(post.serverId, or: ServerData.empty),
        version: ref.read(versionRepoProvider).current,
      ),
      [post.hashCode],
    ),
  );
}
