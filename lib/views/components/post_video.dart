import 'dart:async';

import 'package:async/async.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../model/booru_post.dart';
import '../../provider/downloader.dart';
import '../../provider/video_player.dart';
import '../containers/post.dart';
import '../containers/post_detail.dart';

class PostVideoDisplay extends ConsumerStatefulWidget {
  const PostVideoDisplay({Key? key, required this.booru}) : super(key: key);

  final BooruPost booru;

  @override
  ConsumerState<PostVideoDisplay> createState() => _PostVideoDisplayState();
}

class _PostVideoDisplayState extends ConsumerState<PostVideoDisplay> {
  VideoPlayerController? controller;
  CancelableOperation<FileInfo>? fetchVideo;

  bool hideControl = false;

  get booru => widget.booru;

  void autoHideController() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !hideControl) {
        setState(() {
          hideControl = true;
        });
      }
    });
  }

  void sourceInit() async {
    final cache = DefaultCacheManager();
    final fromCache = await cache.getFileFromCache(booru.displaySrc);
    if (fromCache == null) {
      fetchVideo = CancelableOperation.fromFuture(
        cache.downloadFile(booru.displaySrc),
      );
    }
    final data = fromCache ?? await fetchVideo!.value;

    if (mounted) {
      controller = VideoPlayerController.file(data.file)
        ..setLooping(true)
        ..addListener(() => setState(() {}))
        ..initialize().whenComplete(() {
          autoHideController();
          controller?.setVolume(ref.read(videoPlayerProvider).mute ? 0 : 1);
          controller?.play();
        });
    }
  }

  void toggleFullscreenMode() {
    final isFullscreen = ref.read(postFullscreenProvider.state);
    isFullscreen.state = !isFullscreen.state;
    SystemChrome.setPreferredOrientations(isFullscreen.state &&
            booru.width > booru.height
        ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
        : []);
    SystemChrome.setEnabledSystemUIMode(
      !isFullscreen.state ? SystemUiMode.edgeToEdge : SystemUiMode.immersive,
    );
    autoHideController();
  }

  @override
  void initState() {
    super.initState();
    sourceInit();
  }

  @override
  Widget build(BuildContext context) {
    final vpp = ref.watch(videoPlayerProvider);
    final isFullscreen = ref.watch(postFullscreenProvider.state);
    final downloadNotifier = ref.watch(downloadProvider);
    final downloadStatus = downloadNotifier.getStatus(booru.src);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(isFullscreen.state
            ? SystemUiMode.edgeToEdge
            : SystemUiMode.immersive);
        isFullscreen.state = !isFullscreen.state;
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!(controller?.value.isInitialized ?? false))
            AspectRatio(
              aspectRatio: booru.width / booru.height,
              child: ExtendedImage.network(
                booru.thumbnail,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                enableLoadState: false,
              ),
            ),
          if (controller?.value.isInitialized ?? false)
            AspectRatio(
              aspectRatio: booru.width / booru.height,
              child: VideoPlayer(controller!),
            ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => setState(() => hideControl = !hideControl),
            child: !hideControl
                ? Container(
                    color: Colors.black26,
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        if (controller?.value.isPlaying ?? false) {
                          controller?.pause();
                        } else {
                          controller?.play();
                        }
                      },
                      child: Icon(
                        controller?.value.isPlaying ?? false
                            ? Icons.pause_outlined
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 64.0,
                      ),
                    ),
                  )
                : Container(),
          ),
          if (!hideControl)
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top,
                16,
                MediaQuery.of(context).padding.bottom +
                    (isFullscreen.state ? 24 : 56),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: downloadStatus.status ==
                                    DownloadTaskStatus.running
                                ? (1 * downloadStatus.progress) / 100
                                : 0,
                          ),
                          IconButton(
                            icon: Icon(downloadStatus.status ==
                                    DownloadTaskStatus.complete
                                ? Icons.download_done
                                : Icons.download),
                            onPressed: () {
                              downloadNotifier.download(booru.src);
                            },
                            color: Colors.white,
                            disabledColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          vpp.mute = !vpp.mute;
                          controller?.setVolume(vpp.mute ? 0 : 1);
                        },
                        icon: Icon(
                          vpp.mute ? Icons.volume_mute : Icons.volume_up,
                        ),
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: const Icon(Icons.info),
                        color: Colors.white,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetails(id: booru.id),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFullscreen.state
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen_outlined,
                        ),
                        color: Colors.white,
                        onPressed: toggleFullscreenMode,
                      ),
                    ],
                  ),
                  VideoProgress(controller: controller),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (fetchVideo?.isCompleted == false) {
      fetchVideo!.cancel();
    }

    controller?.removeListener(() => setState(() {}));
    if (controller?.value.isPlaying ?? false) {
      controller?.pause();
    }
    controller?.dispose();
    super.dispose();
  }
}

class VideoProgress extends StatelessWidget {
  const VideoProgress({Key? key, this.controller}) : super(key: key);

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;
    if (ctrl == null || ctrl.value.isInitialized == false) {
      return LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.redAccent.shade700,
        ),
        backgroundColor: Colors.white.withAlpha(20),
      );
    }

    return VideoProgressIndicator(
      ctrl,
      colors: VideoProgressColors(
        playedColor: Colors.redAccent.shade700,
        backgroundColor: Colors.white.withAlpha(20),
      ),
      allowScrubbing: true,
    );
  }
}
