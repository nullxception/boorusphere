import 'dart:async';

import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/booru/post_headers_factory.dart';
import 'package:boorusphere/presentation/provider/download/downloader.dart';
import 'package:boorusphere/presentation/provider/settings/download_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/entity/download_quality.dart';
import 'package:boorusphere/presentation/utils/entity/pixel_size.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/utils/extensions/images.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:boorusphere/presentation/widgets/permissions.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloaderDialog extends ConsumerWidget {
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
    final headers = ref.watch(postHeadersFactoryProvider(post));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(context.t.downloads.title)),
            if (post.sampleFile.isNotEmpty)
              ListTile(
                  title: Text(context.t.fileSample),
                  subtitle: FutureBuilder<PixelSize>(
                    future: post.content.isPhoto && !post.sampleSize.hasPixels
                        ? ExtendedNetworkImageProvider(
                            post.sampleFile,
                            cache: true,
                            headers: headers,
                          ).resolvePixelSize()
                        : Future.value(post.sampleSize),
                    builder: (context, snapshot) {
                      final size = snapshot.data ?? post.sampleSize;
                      return Text('$size, ${post.sampleFile.fileExt}');
                    },
                  ),
                  leading: Icon(_getFileIcon(post.sampleFile)),
                  onTap: () {
                    checkNotificationPermission(context).then((value) {
                      if (value) {
                        onItemClick?.call('sample');
                        ref
                            .read(downloaderProvider)
                            .download(post, url: post.sampleFile);
                      }
                      context.navigator.pop();
                    });
                  }),
            ListTile(
              title: Text(context.t.fileOg),
              subtitle: Text(
                  '${post.originalSize.toString()}, ${post.originalFile.fileExt}'),
              leading: Icon(_getFileIcon(post.originalFile)),
              onTap: () {
                checkNotificationPermission(context).then((value) {
                  if (value) {
                    onItemClick?.call('original');
                    ref.read(downloaderProvider).download(post);
                  }
                  context.navigator.pop();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    Post post, {
    Function(String type)? onItemClick,
  }) async {
    final quality =
        ref.read(downloadSettingStateProvider.select((it) => it.quality));

    if (quality == DownloadQuality.ask) {
      await showModalBottomSheet(
          context: context,
          builder: (_) =>
              DownloaderDialog(post: post, onItemClick: onItemClick));

      return;
    }

    final isGranted = await checkNotificationPermission(context);
    if (!isGranted) return;

    await ref.read(downloaderProvider).download(post,
        url: quality == DownloadQuality.sample
            ? post.sampleFile
            : post.originalFile);
  }
}

Future<bool> checkNotificationPermission(BuildContext context) async {
  final isGranted = await Permission.notification.isGranted;
  if (isGranted) {
    return true;
  }

  final status = await Permission.notification.request();
  if (!status.isGranted && context.mounted) {
    await showSystemAppSettingsDialog(
      context: context,
      title: context.t.downloads.title,
      reason: context.t.downloads.noPermission,
    );
  }
  return status.isGranted;
}
