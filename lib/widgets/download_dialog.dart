import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/post.dart';
import '../../utils/string_ext.dart';
import '../providers/download.dart';

class DownloaderDialog extends HookConsumerWidget {
  const DownloaderDialog({
    Key? key,
    required this.post,
    this.onItemClick,
  }) : super(key: key);

  final Post post;
  final Function(String type)? onItemClick;

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
                    '${post.sampleSize.toString()}, ${post.sampleFile.fileExtension}'),
                leading: Icon(_getFileIcon(post.sampleFile)),
                onTap: () {
                  onItemClick?.call('sample');
                  Navigator.of(context).pop();
                  downloader.download(post, url: post.sampleFile);
                },
              ),
            ListTile(
              title: const Text('Original'),
              subtitle: Text(
                  '${post.originalSize.toString()}, ${post.originalFile.fileExtension}'),
              leading: Icon(_getFileIcon(post.originalFile)),
              onTap: () {
                onItemClick?.call('original');
                Navigator.of(context).pop();
                downloader.download(post);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void show({
    required BuildContext context,
    required Post post,
    Function(String type)? onItemClick,
  }) {
    showModalBottomSheet(
        context: context,
        builder: (_) => DownloaderDialog(post: post, onItemClick: onItemClick));
  }
}
