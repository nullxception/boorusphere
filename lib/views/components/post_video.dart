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
  VideoPlayerController? _controller;

  bool hideControl = false;
  bool isFullscreen = false;

  get booru => widget.booru;

  Future<FileInfo> _getVideoFile(String url) async {
    final cacheManager = DefaultCacheManager();
    return await cacheManager.getFileFromCache(url) ??
        await cacheManager.downloadFile(url);
  }

  void _autoHideController() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !hideControl) {
        setState(() {
          hideControl = true;
        });
      }
    });
  }

  void _sourceInit() async {
    final videoData = await _getVideoFile(booru.displaySrc);
    if (mounted) {
      _controller = VideoPlayerController.file(videoData.file)
        ..setLooping(true)
        ..addListener(() => setState(() {}))
        ..initialize().whenComplete(() {
          _autoHideController();
          _controller?.setVolume(ref.read(videoPlayerProvider).mute ? 0 : 1);
          _controller?.play();
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
    _autoHideController();
  }

  @override
  void initState() {
    _sourceInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final vpp = ref.watch(videoPlayerProvider);
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          _controller?.value.isInitialized ?? false
              ? AspectRatio(
                  aspectRatio: booru.width / booru.height,
                  child: VideoPlayer(_controller!),
                )
              : Container(),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              setState(() => hideControl = !hideControl);
            },
            child: hideControl
                ? Container()
                : Container(
                    color: Colors.black26,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _controller?.value.isPlaying ?? false
                            ? _controller?.pause()
                            : _controller?.play(),
                        child: Icon(
                          _controller?.value.isPlaying ?? false
                              ? Icons.pause_outlined
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 64.0,
                        ),
                      ),
                    ),
                  ),
          ),
          if (!hideControl)
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top,
                16,
                MediaQuery.of(context).padding.bottom +
                    (isFullscreen ? 24 : 56),
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
                          _controller?.setVolume(vpp.mute ? 0 : 1);
                        },
                        icon: Icon(vpp.mute == true
                            ? Icons.volume_mute
                            : Icons.volume_up),
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
                        icon: Icon(isFullscreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen_outlined),
                        color: Colors.white,
                        onPressed: toggleFullscreenMode,
                      ),
                    ],
                  ),
                  VideoProgress(controller: _controller),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.removeListener(() => setState(() {}));
    if (_controller?.value.isPlaying ?? false) {
      _controller?.pause();
    }
    _controller?.dispose();
    super.dispose();
  }
}

class VideoProgress extends StatelessWidget {
  const VideoProgress({Key? key, this.controller}) : super(key: key);

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    final lController = controller;
    if (lController == null || lController.value.isInitialized == false) {
      return LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.redAccent.shade700,
        ),
        backgroundColor: Colors.white.withAlpha(20),
      );
    }

    return VideoProgressIndicator(
      lController,
      colors: VideoProgressColors(
        playedColor: Colors.redAccent.shade700,
        backgroundColor: Colors.white.withAlpha(20),
      ),
      allowScrubbing: true,
    );
  }
}
