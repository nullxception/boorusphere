import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../model/booru_post.dart';
import '../../provider/common.dart';

import '../containers/post_detail.dart';

class PostVideoDisplay extends StatefulWidget {
  const PostVideoDisplay({Key? key, required this.content}) : super(key: key);

  final BooruPost content;

  @override
  _PostVideoDisplayState createState() => _PostVideoDisplayState();
}

class _PostVideoDisplayState extends State<PostVideoDisplay> {
  VideoPlayerController? _controller;

  bool _hidePlayerControl = false;
  bool _videoFullscreen = false;

  Future<File?> _downloadAndCacheVideo(String url) async {
    final cacheManager = DefaultCacheManager();
    FileInfo? fileInfo;
    fileInfo =
        await cacheManager.getFileFromCache(url); // Get video from cache first
    if (fileInfo?.file == null) {
      fileInfo = await cacheManager
          .downloadFile(url); // Download video if not cached yet
    }
    return fileInfo?.file;
  }

  void _autoHideController() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_hidePlayerControl) {
        setState(() {
          _hidePlayerControl = true;
        });
      }
    });
  }

  @override
  void initState() {
    _downloadAndCacheVideo(widget.content.displaySrc).then((file) {
      if (file != null) {
        _controller = VideoPlayerController.file(file)
          ..setLooping(true)
          ..addListener(() => setState(() {}))
          ..initialize().then((_) {
            _autoHideController();
            _controller?.play();
          });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: widget.content.width / widget.content.height,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _controller?.value.isInitialized ?? false
                ? VideoPlayer(_controller!)
                : Container(),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (_hidePlayerControl) {
                  _autoHideController();
                }
                setState(() => _hidePlayerControl = !_hidePlayerControl);
              },
              child: _hidePlayerControl
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
            if (!_hidePlayerControl && _controller != null)
              VideoProgressIndicator(
                _controller!,
                colors: VideoProgressColors(
                  playedColor: Colors.redAccent.shade700,
                  backgroundColor: Colors.white.withAlpha(20),
                ),
                allowScrubbing: true,
              )
            else if (_controller == null ||
                _controller?.value.isInitialized == false)
              LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.redAccent.shade700,
                ),
                backgroundColor: Colors.white.withAlpha(20),
              ),
            if (!_hidePlayerControl)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.info),
                    color: Colors.white,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetails(data: widget.content),
                      ),
                    ),
                  ),
                  Consumer(
                    builder: (context, watch, child) {
                      var style = watch(styleProvider);
                      return IconButton(
                        icon: Icon(style.isForcedLandscape
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen_outlined),
                        color: Colors.white,
                        onPressed: () {
                          _videoFullscreen = !_videoFullscreen;
                          if (widget.content.width > widget.content.height) {
                            style.setForcedLandscape(
                              enable: _videoFullscreen,
                              notify: false,
                            );
                          }
                          style.setFullScreen(enable: _videoFullscreen);

                          setState(() {
                            _hidePlayerControl = _videoFullscreen;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.content.displayType == PostType.video) {
      _controller?.removeListener(() => setState(() {}));

      if (_controller?.value.isPlaying ?? false) {
        _controller?.pause();
      }
      _controller?.dispose();
    }
    super.dispose();
  }
}
