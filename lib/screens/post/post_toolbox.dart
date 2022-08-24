import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../entity/post.dart';
import '../../routes/routes.dart';
import '../../services/download.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../utils/extensions/number.dart';
import '../../widgets/download_dialog.dart';

class PostToolbox extends HookConsumerWidget {
  const PostToolbox(this.post, {super.key});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloader = ref.watch(downloadProvider);
    final downloadProgress = downloader.getProgressByURL(post.originalFile);
    final viewPadding = context.mediaQuery.viewPadding;
    final safePaddingBottom = useState(viewPadding.bottom);
    if (viewPadding.bottom > safePaddingBottom.value) {
      safePaddingBottom.value = viewPadding.bottom;
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      height: safePaddingBottom.value + 86,
      alignment: Alignment.bottomRight,
      padding: EdgeInsets.only(bottom: safePaddingBottom.value + 8, right: 8),
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
            onPressed: () => context.router.push(PostDetailsRoute(post: post)),
          ),
        ],
      ),
    );
  }
}
