import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:separated_row/separated_row.dart';

import '../../data/download_entry.dart';
import '../../data/download_status.dart';
import '../../providers/download.dart';
import '../../providers/settings/downloads/group_by_server.dart';
import '../../utils/string_ext.dart';
import '../../widgets/download_dialog.dart';
import '../post/post_detail.dart';

class DownloadEntryView extends ConsumerWidget {
  const DownloadEntryView({super.key, required this.entry});

  final DownloadEntry entry;

  IconData downloadStatusIconOf(DownloadEntry entry, DownloadStatus status) {
    switch (status) {
      case DownloadStatus.downloaded:
        return entry.isFileExists
            ? Icons.download_done_rounded
            : Icons.error_outline_rounded;
      case DownloadStatus.downloading:
        return Icons.downloading_rounded;
      case DownloadStatus.canceled:
      case DownloadStatus.failed:
        return Icons.cancel_rounded;
      default:
        return Icons.file_open;
    }
  }

  Color downloadStatusColorOf(
      DownloadEntry entry, DownloadStatus status, ColorScheme scheme) {
    switch (status) {
      case DownloadStatus.downloaded:
        return entry.isFileExists
            ? Colors.lightBlueAccent
            : scheme.onBackground.withAlpha(125);
      case DownloadStatus.canceled:
      case DownloadStatus.failed:
        return Colors.pinkAccent;
      default:
        return scheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloader = ref.watch(downloadProvider);
    final groupByServer = ref.watch(groupByServerProvider);
    final progress = downloader.getProgress(entry.id);

    return ListTile(
      title: Text(
        Uri.decodeFull(downloader.getFileNameFromUrl(entry.destination)),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SeparatedRow(
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          children: [
            if (progress.status.isDownloading || progress.status.isPending) ...[
              SizedBox(
                height: 18,
                width: 18,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: CircularProgressIndicator(
                    value: progress.status.isPending
                        ? null
                        : (1 * progress.progress) / 100,
                    strokeWidth: 2.5,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                  ),
                ),
              ),
              Text('${progress.progress}%'),
            ] else
              Icon(
                downloadStatusIconOf(entry, progress.status),
                color: downloadStatusColorOf(
                  entry,
                  progress.status,
                  Theme.of(context).colorScheme,
                ),
                size: 18,
              ),
            if (progress.status.isDownloaded && !entry.isFileExists)
              const Text('File moved or missing')
            else
              Text(progress.status.name.capitalized),
            if (!groupByServer) ...[
              const Text('•'),
              Text(entry.post.serverName),
            ],
          ],
        ),
      ),
      leading: ExtendedImage.network(
        entry.post.previewFile,
        width: 42,
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        fit: BoxFit.cover,
      ),
      trailing: _EntryPopupMenu(entry: entry),
      dense: true,
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      onTap: !progress.status.isDownloaded || !entry.isFileExists
          ? null
          : () => downloader.openEntryFile(id: entry.id),
    );
  }
}

class _EntryPopupMenu extends ConsumerWidget {
  const _EntryPopupMenu({required this.entry});

  final DownloadEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloader = ref.watch(downloadProvider);
    final progress = downloader.getProgress(entry.id);

    return PopupMenuButton(
      onSelected: (value) {
        switch (value) {
          case 'redownload':
            DownloaderDialog.show(
              context: context,
              post: entry.post,
              onItemClick: (type) async {
                await downloader.clearEntry(id: entry.id);
              },
            );
            break;
          case 'retry':
            downloader.retryEntry(id: entry.id);
            break;
          case 'cancel':
            downloader.cancelEntry(id: entry.id);
            break;
          case 'clear':
            downloader.clearEntry(id: entry.id);
            break;
          case 'show-detail':
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostDetailsPage(post: entry.post)),
            );
            break;
          default:
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          if (progress.status.isDownloaded && !entry.isFileExists)
            const PopupMenuItem(
              value: 'redownload',
              child: Text('Redownload'),
            ),
          if (progress.status.isCanceled || progress.status.isFailed)
            const PopupMenuItem(
              value: 'retry',
              child: Text('Retry'),
            ),
          if (progress.status.isDownloading)
            const PopupMenuItem(
              value: 'cancel',
              child: Text('Cancel'),
            ),
          const PopupMenuItem(
            value: 'show-detail',
            child: Text('Show detail'),
          ),
          const PopupMenuItem(
            value: 'clear',
            child: Text('Clear'),
          ),
        ];
      },
    );
  }
}
