import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime/mime.dart';

import '../../model/booru_post.dart';
import '../../provider/downloader.dart';

class DownloaderDialog extends HookConsumerWidget {
  const DownloaderDialog({
    Key? key,
    required this.booru,
  }) : super(key: key);
  final BooruPost booru;

  String _getFileExt(String url) {
    try {
      return url.split('/').last.split('.').last;
    } catch (e) {
      return '';
    }
  }

  IconData _getFileIcon(String url) {
    final name = url.split('/').last;
    final mime = lookupMimeType(name) ?? '';
    if (mime.startsWith('video')) {
      return Icons.video_library;
    } else if (mime.startsWith('image')) {
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
            if (booru.hasDisplaySrc)
              ListTile(
                title: Text('Sample file (${_getFileExt(booru.displaySrc)})'),
                leading: Icon(_getFileIcon(booru.displaySrc)),
                onTap: () {
                  Navigator.of(context).pop();
                  downloader.download(booru, url: booru.displaySrc);
                },
              ),
            ListTile(
              title: Text('Original file (${_getFileExt(booru.src)})'),
              leading: Icon(_getFileIcon(booru.src)),
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
