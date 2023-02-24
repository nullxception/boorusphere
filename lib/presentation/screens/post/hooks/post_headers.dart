import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/provider/booru/post_headers_factory.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Map<String, String> usePostHeaders(WidgetRef ref, Post post) {
  return useMemoized(
    () => ref.read(postHeadersFactoryProvider).build(post),
    [post.hashCode],
  );
}
