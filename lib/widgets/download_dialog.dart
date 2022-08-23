import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../entity/post.dart';
import '../entity/pixel_size.dart';
import '../services/download.dart';
import '../source/page.dart';
import '../utils/extensions/buildcontext.dart';
import '../utils/extensions/imageprovider.dart';
import '../utils/extensions/string.dart';

class DownloaderDialog extends HookConsumerWidget {
  const DownloaderDialog({
    super.key,
    required this.post,
    this.onItemClick,
  });

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
    final pageCookies = ref.watch(pageCookieProvider);
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
                subtitle: FutureBuilder<PixelSize>(
                  future: post.contentType == PostType.photo &&
                          !post.sampleSize.hasPixels
                      ? ExtendedNetworkImageProvider(
                          post.sampleFile,
                          cache: true,
                          headers: {
                            'Referer': post.postUrl,
                            'Cookie': CookieManager.getCookies(pageCookies),
                          },
                        ).resolvePixelSize()
                      : Future.value(post.sampleSize),
                  builder: (context, snapshot) {
                    final size = snapshot.data ?? post.sampleSize;
                    return Text('$size, ${post.sampleFile.fileExtension}');
                  },
                ),
                leading: Icon(_getFileIcon(post.sampleFile)),
                onTap: () {
                  onItemClick?.call('sample');
                  context.navigator.pop();
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
                context.navigator.pop();
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
