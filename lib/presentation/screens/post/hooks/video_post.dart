import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/provider/booru/post_headers_factory.dart';
import 'package:boorusphere/presentation/provider/cache.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

VideoPlayerController? useVideoPost(
  WidgetRef ref,
  Post post,
) {
  return use(_VideoPostHook(ref, post));
}

class _VideoPostHook extends Hook<VideoPlayerController?> {
  const _VideoPostHook(this.ref, this.post);

  final WidgetRef ref;
  final Post post;

  @override
  _VideoPostState createState() => _VideoPostState();
}

class _VideoPostState
    extends HookState<VideoPlayerController?, _VideoPostHook> {
  _VideoPostState();
  VideoPlayerController? controller;

  WidgetRef get ref => hook.ref;
  Post get post => hook.post;

  @override
  void initHook() {
    super.initHook();
    createController().then((value) {
      setState(() {
        controller = value..setLooping(true);
      });
    });
  }

  Future<VideoPlayerController> createController() async {
    final cache = ref.read(cacheManagerProvider);
    final cookieJar = ref.read(cookieJarProvider);
    final cookies = await cookieJar.loadForRequest(post.content.url.toUri());
    final headers =
        ref.read(postHeadersFactoryProvider(post, cookies: cookies));
    return VideoPlayerController.file(
      await cache.getSingleFile(post.content.url, headers: headers),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
  }

  @override
  VideoPlayerController? build(BuildContext context) => controller;

  @override
  void dispose() {
    controller?.pause();
    controller?.dispose();
    super.dispose();
  }

  @override
  String get debugLabel => 'useVideoPost';
}
