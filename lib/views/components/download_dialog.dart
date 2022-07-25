import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/post.dart';
import '../../provider/downloader.dart';
import '../../util/string_ext.dart';

class DownloaderDialog extends HookConsumerWidget {
  const DownloaderDialog({
    Key? key,
    required this.post,
  }) : super(key: key);
  final Post post;

  IconData _getFileIcon(String url) {
    if (url.mimeType.startsWith('video')) {
      return Icons.video_library;
    } else if (url.mimeType.startsWith('image')) {
      return Icons.photo;
    } else {
      return Icons.file_present;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloader = ref.watch(downloadProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('Download')),
            if (post.sampleFile.isNotEmpty)
              ListTile(
                title: const Text('Sample'),
                subtitle: Text(
                    '${post.sampleSize.toString()}, ${post.sampleFile.ext}'),
                leading: Icon(_getFileIcon(post.sampleFile)),
                onTap: () {
                  Navigator.of(context).pop();
                  downloader.download(post, url: post.sampleFile);
                },
              ),
            ListTile(
              title: const Text('Original'),
              subtitle: Text(
                  '${post.originalSize.toString()}, ${post.originalFile.ext}'),
              leading: Icon(_getFileIcon(post.originalFile)),
              onTap: () {
                Navigator.of(context).pop();
                downloader.download(post);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void show({required BuildContext context, required Post post}) {
    showModalBottomSheet(
        context: context, builder: (_) => DownloaderDialog(post: post));
  }
}
