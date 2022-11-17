import 'dart:async';

import 'package:boorusphere/data/repository/booru/entity/pixel_size.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/services/download.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/booru/extension/post.dart';
import 'package:boorusphere/presentation/widgets/permissions.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:boorusphere/utils/extensions/imageprovider.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(context.t.downloader.title)),
            if (post.sampleFile.isNotEmpty)
              ListTile(
                  title: Text(context.t.fileSample),
                  subtitle: FutureBuilder<PixelSize>(
                    future: post.content.isPhoto && !post.sampleSize.hasPixels
                        ? ExtendedNetworkImageProvider(
                            post.sampleFile,
                            cache: true,
                            headers: post.getHeaders(ref),
                          ).resolvePixelSize()
                        : Future.value(post.sampleSize),
                    builder: (context, snapshot) {
                      final size = snapshot.data ?? post.sampleSize;
                      return Text('$size, ${post.sampleFile.fileExtension}');
                    },
                  ),
                  leading: Icon(_getFileIcon(post.sampleFile)),
                  onTap: () async {
                    if (!await checkPermission(context: context)) {
                      context.navigator.pop();
                      return;
                    }

                    onItemClick?.call('sample');
                    unawaited(downloader.download(post, url: post.sampleFile));
                    context.navigator.pop();
                  }),
            ListTile(
              title: Text(context.t.fileOG),
              subtitle: Text(
                  '${post.originalSize.toString()}, ${post.originalFile.fileExtension}'),
              leading: Icon(_getFileIcon(post.originalFile)),
              onTap: () async {
                if (!await checkPermission(context: context)) {
                  context.navigator.pop();
                  return;
                }

                onItemClick?.call('original');
                unawaited(downloader.download(post));
                context.navigator.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  static show({
    required BuildContext context,
    required Post post,
    Function(String type)? onItemClick,
  }) {
    showModalBottomSheet(
        context: context,
        builder: (_) => DownloaderDialog(post: post, onItemClick: onItemClick));
  }

  Future<bool> checkPermission({required BuildContext context}) async {
    final isGranted = await Permission.notification.isGranted;
    if (isGranted) {
      return true;
    }

    final status = await Permission.notification.request();
    if (!status.isGranted) {
      await showSystemAppSettingsDialog(
        context: context,
        title: context.t.downloader.title,
        reason: context.t.downloader.noPermission,
      );
    }
    return status.isGranted;
  }
}
