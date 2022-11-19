import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
import 'package:boorusphere/data/repository/download/entity/download_progress.dart';
import 'package:boorusphere/data/repository/download/entity/download_status.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/booru/extension/post.dart';
import 'package:boorusphere/presentation/provider/download/downloader.dart';
import 'package:boorusphere/presentation/provider/server_data.dart';
import 'package:boorusphere/presentation/routes/routes.dart';
import 'package:boorusphere/presentation/widgets/download_dialog.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:boorusphere/utils/extensions/number.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:separated_row/separated_row.dart';

class DownloadEntryView extends ConsumerWidget {
  const DownloadEntryView({
    super.key,
    required this.entry,
    required this.progress,
    required this.groupByServer,
  });

  final DownloadEntry entry;
  final DownloadProgress progress;
  final bool groupByServer;

  IconData _buildStatusIcon() {
    switch (progress.status) {
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

  Color _buildStatusColor(ColorScheme scheme) {
    switch (progress.status) {
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

  String _buildStatusDesc(BuildContext context) {
    if (progress.status.isDownloaded && !entry.isFileExists) {
      return context.t.downloader.noFile;
    }

    final status = context.t.downloader.status;
    switch (progress.status) {
      case DownloadStatus.pending:
        return status.pending;
      case DownloadStatus.downloading:
        return status.downloading;
      case DownloadStatus.downloaded:
        return status.downloaded;
      case DownloadStatus.failed:
        return status.failed;
      case DownloadStatus.canceled:
        return status.canceled;
      case DownloadStatus.paused:
        return status.paused;
      default:
        return status.empty;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref
        .watch(serverDataStateProvider.notifier)
        .getById(entry.post.serverId);

    return ListTile(
      title: Text(
        entry.destination.fileName.asDecoded,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Wrap(
          children: [
            SeparatedRow(
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (progress.status.isDownloading ||
                    progress.status.isPending) ...[
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: CircularProgressIndicator(
                        value: progress.status.isPending
                            ? null
                            : progress.progress.ratio,
                        strokeWidth: 2.5,
                        backgroundColor: context.colorScheme.surfaceVariant,
                      ),
                    ),
                  ),
                  Text('${progress.progress}%'),
                ] else
                  Icon(
                    _buildStatusIcon(),
                    color: _buildStatusColor(context.colorScheme),
                    size: 18,
                  ),
                Text(_buildStatusDesc(context)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 18,
                  child: Center(child: Text('•')),
                ),
                Text(server.name),
              ],
            ),
          ],
        ),
      ),
      leading: ExtendedImage.network(
        entry.post.previewFile,
        headers: entry.post.getHeaders(ref),
        width: 42,
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        fit: BoxFit.cover,
      ),
      trailing: _EntryPopupMenu(entry: entry, progress: progress),
      dense: true,
      onTap: !progress.status.isDownloaded || !entry.isFileExists
          ? null
          : () => ref.read(downloaderProvider).openFile(id: entry.id),
    );
  }
}

class _EntryPopupMenu extends ConsumerWidget {
  const _EntryPopupMenu({
    required this.entry,
    required this.progress,
  });

  final DownloadEntry entry;
  final DownloadProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
      onSelected: (value) {
        final downloader = ref.read(downloaderProvider);
        switch (value) {
          case 'redownload':
            DownloaderDialog.show(
              context: context,
              post: entry.post,
              onItemClick: (type) async {
                await downloader.clear(id: entry.id);
              },
            );
            break;
          case 'retry':
            downloader.retry(id: entry.id);
            break;
          case 'cancel':
            downloader.cancel(id: entry.id);
            break;
          case 'clear':
            downloader.clear(id: entry.id);
            break;
          case 'show-detail':
            context.router.push(PostDetailsRoute(post: entry.post));
            break;
          default:
            break;
        }
      },
      itemBuilder: (context) {
        return [
          if (progress.status.isDownloaded && !entry.isFileExists)
            PopupMenuItem(
              value: 'redownload',
              child: Text(context.t.downloader.redownload),
            ),
          if (progress.status.isCanceled || progress.status.isFailed)
            PopupMenuItem(
              value: 'retry',
              child: Text(context.t.retry),
            ),
          if (progress.status.isDownloading)
            PopupMenuItem(
              value: 'cancel',
              child: Text(context.t.cancel),
            ),
          PopupMenuItem(
            value: 'show-detail',
            child: Text(context.t.downloader.detail),
          ),
          PopupMenuItem(
            value: 'clear',
            child: Text(context.t.clear),
          ),
        ];
      },
    );
  }
}
