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

  void _precachePosts(i, showOG) {
    if (!context.mounted) return;

    final next = i + 1;
    final prev = i - 1;
    final posts = hook.posts;

    if (prev >= 0) {
      _precacheImagePost(posts.elementAt(prev), showOG);
    }

    if (next < posts.length) {
      _precacheImagePost(posts.elementAt(next), showOG);
    }
  }

  @override
  _Precacher build(BuildContext context) => _precachePosts;

  @override
  String get debugLabel => 'usePrecachePosts';
}
