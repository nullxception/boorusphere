import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/provider/booru/post_headers_factory.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:collection/collection.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void Function(int index, bool loadOriginal) usePrecachePosts(
  WidgetRef ref,
  Iterable<Post> posts, {
  int range = 2,
}) {
  return use(_PrecachePostsHook(ref, posts, range));
}

typedef _Precacher = void Function(int, bool);

class _PrecachePostsHook extends Hook<_Precacher> {
  const _PrecachePostsHook(this.ref, this.posts, this.range);

  final WidgetRef ref;
  final Iterable<Post> posts;
  final int range;

  @override
  HookState<_Precacher, _PrecachePostsHook> createState() {
    return _PrecachePostsState();
  }
}

class _PrecachePostsState extends HookState<_Precacher, _PrecachePostsHook> {
  _PrecachePostsState();

  Future<void> _precacheImagePost(Post post, bool og) async {
    if (!post.content.isPhoto || !context.mounted) return;
    final image = ExtendedNetworkImageProvider(
      og ? post.originalFile : post.content.url,
      headers: hook.ref.read(postHeadersFactoryProvider(post)),
      cache: true,
      retries: 3,
    );
    final status = await image.obtainCacheStatus(
      configuration: ImageConfiguration.empty,
    );
    if (context.mounted && (status?.untracked ?? true)) {
      await precacheImage(image, context);
    }
  }

  Iterable<Post> _postsInRange(int curr, int range) {
    final prev = hook.posts.whereIndexed((index, element) {
      return index < curr && index >= curr - range;
    });

    final next = hook.posts.whereIndexed((index, element) {
      return index > curr && index <= curr + range;
    });

    return {...prev, ...next};
  }

  void _precachePosts(i, showOG) {
    if (!context.mounted) return;
    for (var post in _postsInRange(i, hook.range)) {
      _precacheImagePost(post, showOG);
    }
  }

  @override
  _Precacher build(BuildContext context) => _precachePosts;

  @override
  String get debugLabel => 'usePrecachePosts';
}
