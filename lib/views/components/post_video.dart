import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../model/booru_post.dart';
import '../../provider/video_player.dart';
import '../containers/post_detail.dart';

class PostVideoDisplay extends ConsumerStatefulWidget {
  const PostVideoDisplay({Key? key, required this.booru}) : super(key: key);

  final BooruPost booru;

  @override
  _PostVideoDisplayState createState() => _PostVideoDisplayState();
}

class _PostVideoDisplayState extends ConsumerState<PostVideoDisplay> {
  VideoPlayerController? controller;

  bool hideControl = false;
  bool isFullscreen = false;

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
    final videoData = await cache.getFileFromCache(booru.displaySrc) ??
        await cache.downloadFile(booru.displaySrc);

    if (mounted) {
      controller = VideoPlayerController.file(videoData.file)
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
    setState(() {
      isFullscreen = !isFullscreen;
      SystemChrome.setPreferredOrientations(isFullscreen &&
              booru.width > booru.height
          ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
          : []);
      SystemChrome.setEnabledSystemUIMode(
        !isFullscreen ? SystemUiMode.edgeToEdge : SystemUiMode.immersive,
      );
    });
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
    return Stack(
      alignment: Alignment.center,
      children: [
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
              MediaQuery.of(context).padding.bottom + (isFullscreen ? 24 : 56),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
                        isFullscreen
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
    );
  }

  @override
  void dispose() {
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
