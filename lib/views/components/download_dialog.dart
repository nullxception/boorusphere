import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/booru_post.dart';
import '../../provider/downloader.dart';
import '../../util/string_ext.dart';

class DownloaderDialog extends HookConsumerWidget {
  const DownloaderDialog({
    Key? key,
    required this.booru,
  }) : super(key: key);
  final BooruPost booru;

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
            if (booru.sampleFile.isNotEmpty)
              ListTile(
                title: const Text('Sample'),
                subtitle: Text(
                    '${booru.sampleSize.toString()}, ${booru.sampleFile.ext}'),
                leading: Icon(_getFileIcon(booru.sampleFile)),
                onTap: () {
                  Navigator.of(context).pop();
                  downloader.download(booru, url: booru.sampleFile);
                },
              ),
            ListTile(
              title: const Text('Original'),
              subtitle: Text(
                  '${booru.originalSize.toString()}, ${booru.originalFile.ext}'),
              leading: Icon(_getFileIcon(booru.originalFile)),
              onTap: () {
                Navigator.of(context).pop();
                downloader.download(booru);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void show({required BuildContext context, required BooruPost booru}) {
    showModalBottomSheet(
        context: context, builder: (_) => DownloaderDialog(booru: booru));
  }
}
