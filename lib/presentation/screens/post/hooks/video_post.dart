import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/provider/booru/post_headers_factory.dart';
import 'package:boorusphere/presentation/provider/cache.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

class VideoPostSource {
  VideoPostSource({
    this.progress = const DownloadProgress('', 0, 0),
    this.controller,
  });

  final DownloadProgress progress;
  final VideoPlayerController? controller;

  VideoPostSource copyWith({
    DownloadProgress? progress,
    VideoPlayerController? controller,
  }) {
    return VideoPostSource(
      progress: progress ?? this.progress,
      controller: controller ?? this.controller,
    );
  }

  @override
  bool operator ==(covariant VideoPostSource other) {
    if (identical(this, other)) return true;

    return other.progress == progress && other.controller == controller;
  }

  @override
  int get hashCode => progress.hashCode ^ controller.hashCode;
}

VideoPostSource useVideoPostSource(WidgetRef ref, Post post) {
  return use(_VideoPostHook(ref, post));
}

class _VideoPostHook extends Hook<VideoPostSource> {
  const _VideoPostHook(this.ref, this.post);

  final WidgetRef ref;
  final Post post;

  @override
  _VideoPostState createState() => _VideoPostState();
}

class _VideoPostState extends HookState<VideoPostSource, _VideoPostHook> {
  _VideoPostState();

  VideoPlayerController? controller;
  VideoPostSource source = VideoPostSource();

  void onFileStream(FileResponse event) {
    if (!context.mounted) return;

    if (event is DownloadProgress) {
      setState(() {
        source = source.copyWith(progress: event);
      });
    } else if (event is FileInfo) {
      controller = VideoPlayerController.file(event.file,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
        ..setLooping(true);
      final size = event.file.statSync().size;
      final prog = DownloadProgress(event.originalUrl, size, size);

      setState(() {
        source = source.copyWith(controller: controller, progress: prog);
      });
    }
  }

  Future<void> createController() async {
    final cache = hook.ref.read(cacheManagerProvider);
    final cookieJar = hook.ref.read(cookieJarProvider);
    final cookies =
        await cookieJar.loadForRequest(hook.post.content.url.toUri());
    final headers =
        hook.ref.read(postHeadersFactoryProvider(hook.post, cookies: cookies));

    cache
        .getFileStream(hook.post.content.url,
            headers: headers, withProgress: true)
        .listen(onFileStream);
  }

  @override
  void initHook() {
    super.initHook();
    createController();
  }

  @override
  VideoPostSource build(BuildContext context) => source;

  @override
  void dispose() {
    controller?.pause();
    controller?.dispose();
    super.dispose();
  }

  @override
  String get debugLabel => 'useVideoPost';
}
