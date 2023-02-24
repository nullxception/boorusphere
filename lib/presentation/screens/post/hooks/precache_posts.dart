import 'dart:async';

import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/provider/booru/post_headers_factory.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void Function(int index, bool loadOriginal) usePrecachePosts(
  WidgetRef ref,
  Iterable<Post> posts,
) {
  return use(_PrecachePostsHook(ref, posts));
}

typedef _Precacher = void Function(int, bool);

class _PrecachePostsHook extends Hook<_Precacher> {
  const _PrecachePostsHook(this.ref, this.posts);

  final WidgetRef ref;
  final Iterable<Post> posts;

  @override
  _PrecachePostsState createState() => _PrecachePostsState();
}

class _PrecachePostsState extends HookState<_Precacher, _PrecachePostsHook> {
  _PrecachePostsState();

  bool _mounted = true;

  Future<void> _precache(
    Post post,
    bool displayOriginal,
  ) async {
    if (!post.content.isPhoto || !_mounted) return;
    final ref = hook.ref;
    unawaited(precacheImage(
      ExtendedNetworkImageProvider(
        displayOriginal ? post.originalFile : post.content.url,
        headers: ref.read(postHeadersFactoryProvider).build(post),
        // params below follows the default value on
        // the ExtendedImage.network() factory
        cache: true,
        retries: 3,
      ),
      context,
    ));
  }

  @override
  _Precacher build(BuildContext context) => (i, showOG) {
        if (!_mounted) return;

        final next = i + 1;
        final prev = i - 1;
        final posts = hook.posts;

        if (prev >= 0) {
          _precache(posts.elementAt(prev), showOG);
        }

        if (next < posts.length) {
          _precache(posts.elementAt(next), showOG);
        }
      };

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  String get debugLabel => 'usePrecachePosts';
}
