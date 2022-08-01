import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../entity/post.dart';
import '../../services/download.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../utils/extensions/number.dart';
import '../../widgets/download_dialog.dart';
import 'post_detail.dart';

class PostToolbox extends HookConsumerWidget {
  const PostToolbox(this.post, {Key? key}) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloader = ref.watch(downloadProvider);
    final downloadProgress = downloader.getProgressByURL(post.originalFile);
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      height: 86 + safeBottom,
      padding: EdgeInsets.only(bottom: safeBottom + 8, right: 8),
      alignment: Alignment.bottomRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: downloadProgress.status.isDownloading
                    ? downloadProgress.progress.ratio
                    : 0,
              ),
              IconButton(
                padding: const EdgeInsets.all(16),
                icon: Icon(downloadProgress.status.isDownloaded
                    ? Icons.download_done
                    : Icons.download),
                onPressed: () {
                  DownloaderDialog.show(context: context, post: post);
                },
                disabledColor: context.colorScheme.primary,
              ),
            ],
          ),
          IconButton(
            padding: const EdgeInsets.all(16),
            icon: const Icon(Icons.link_outlined),
            onPressed: () => launchUrlString(post.originalFile,
                mode: LaunchMode.externalApplication),
          ),
          IconButton(
            padding: const EdgeInsets.all(16),
            icon: const Icon(Icons.info),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostDetailsPage(post: post)),
            ),
          ),
        ],
      ),
    );
  }
}
