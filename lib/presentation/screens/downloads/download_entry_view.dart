import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_entry.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_progress.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_status.dart';
import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/booru/post_headers_factory.dart';
import 'package:boorusphere/presentation/provider/download/download_state.dart';
import 'package:boorusphere/presentation/provider/download/downloader.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/shared_storage_handle.dart';
import 'package:boorusphere/presentation/routes/app_router.gr.dart';
import 'package:boorusphere/presentation/screens/home/search_session.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/widgets/download_dialog.dart';
import 'package:boorusphere/utils/extensions/number.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:separated_row/separated_row.dart';

class DownloadEntryView extends ConsumerWidget {
  const DownloadEntryView({
    super.key,
    required this.entry,
    required this.groupByServer,
  });

  final DownloadEntry entry;
  final bool groupByServer;

  IconData _buildStatusIcon(DownloadProgress progress, bool isFileExists) {
    switch (progress.status) {
      case DownloadStatus.downloaded:
        return isFileExists
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

  Color _buildStatusColor(
      ColorScheme scheme, DownloadProgress progress, bool isFileExists) {
    switch (progress.status) {
      case DownloadStatus.downloaded:
        return isFileExists
            ? Colors.lightBlueAccent
            : scheme.onBackground.withAlpha(125);
      case DownloadStatus.canceled:
      case DownloadStatus.failed:
        return Colors.pinkAccent;
      default:
        return scheme.onSurface;
    }
  }

  String _buildStatusDesc(
      BuildContext context, DownloadProgress progress, bool isFileExists) {
    if (progress.status.isDownloaded && !isFileExists) {
      return context.t.downloads.noFile;
    }

    final status = context.t.downloads.status;
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
    final servers = ref.watch(serverStateProvider);
    final headers = ref.watch(postHeadersFactoryProvider(entry.post));
    final progress = ref.watch(downloadProgressStateProvider).getById(entry.id);
    final isFileExists =
        ref.watch(sharedStorageHandleProvider).fileExists(entry.dest);

    return ListTile(
      title: Text(
        Uri.decodeFull(entry.dest.fileName),
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
                    _buildStatusIcon(progress, isFileExists),
                    color: _buildStatusColor(
                        context.colorScheme, progress, isFileExists),
                    size: 18,
                  ),
                Text(_buildStatusDesc(context, progress, isFileExists)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 18,
                  child: Center(child: Text('•')),
                ),
                Text(servers.getById(entry.post.serverId).name),
              ],
            ),
          ],
        ),
      ),
      leading: ExtendedImage.network(
        entry.post.previewFile,
        headers: headers,
        width: 42,
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        fit: BoxFit.cover,
      ),
      trailing: _EntryPopupMenu(
        entry: entry,
        progress: progress,
        server: servers.getById(entry.post.serverId),
      ),
      dense: true,
      onTap: !progress.status.isDownloaded || !isFileExists
          ? null
          : () => ref.read(downloaderProvider).openFile(id: entry.id),
    );
  }
}

class DownloadImagePreview extends HookWidget {
  const DownloadImagePreview({
    super.key,
    required this.entry,
    required this.headers,
  });

  final DownloadEntry entry;
  final Map<String, String>? headers;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      entry.post.previewFile,
      headers: headers,
      width: 42,
      shape: BoxShape.rectangle,
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      fit: BoxFit.cover,
    );
  }
}

class _EntryPopupMenu extends ConsumerWidget {
  const _EntryPopupMenu({
    required this.entry,
    required this.progress,
    required this.server,
  });

  final DownloadEntry entry;
  final DownloadProgress progress;
  final Server server;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFileExists =
        ref.watch(sharedStorageHandleProvider).fileExists(entry.dest);

    return PopupMenuButton(
      onSelected: (value) {
        final downloader = ref.read(downloaderProvider);
        switch (value) {
          case 'redownload':
            DownloaderDialog.show(
              context,
              ref,
              entry.post,
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
            context.router.push(PostDetailsRoute(
              post: entry.post,
              session: ref.read(searchSessionProvider),
            ));
            break;
          default:
            break;
        }
      },
      itemBuilder: (context) {
        return [
          if (progress.status.isDownloaded && !isFileExists)
            PopupMenuItem(
              value: 'redownload',
              child: Text(context.t.downloads.redownload),
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
            child: Text(context.t.downloads.detail),
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
