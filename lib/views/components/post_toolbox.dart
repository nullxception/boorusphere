import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../model/booru_post.dart';
import '../../provider/downloader.dart';
import '../containers/post_detail.dart';

class PostToolbox extends HookConsumerWidget {
  const PostToolbox(this.booru, {Key? key}) : super(key: key);

  final BooruPost booru;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloader = ref.watch(downloadProvider);
    final downloadProgress = downloader.getProgressByURL(booru.src);

    return Container(
      color: Colors.black38,
      height: 64 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: downloadProgress.status.isDownloading
                    ? (1 * downloadProgress.progress) / 100
                    : 0,
              ),
              IconButton(
                icon: Icon(downloadProgress.status.isDownloaded
                    ? Icons.download_done
                    : Icons.download),
                onPressed: () {
                  downloader.download(booru);
                },
                color: Colors.white,
                disabledColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.link_outlined),
            onPressed: () => launchUrlString(booru.src,
                mode: LaunchMode.externalApplication),
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.info),
            color: Colors.white,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostDetailsPage(booru: booru)),
            ),
          ),
        ],
      ),
    );
  }
}
