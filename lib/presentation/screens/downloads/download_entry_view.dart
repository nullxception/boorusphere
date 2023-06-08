import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_entry.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_status.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/booru/post_headers_factory.dart';
import 'package:boorusphere/presentation/provider/download/downloader.dart';
import 'package:boorusphere/presentation/provider/download/entity/download_item.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
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

class DownloadItemView extends ConsumerWidget {
  const DownloadItemView({
    super.key,
    required this.item,
    required this.groupByServer,
  });

  final DownloadItem item;
  final bool groupByServer;

  IconData _buildStatusIcon() {
    switch (item.progress.status) {
      case DownloadStatus.downloaded:
        return item.entry.isFileExists
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
    switch (item.progress.status) {
      case DownloadStatus.downloaded:
        return item.entry.isFileExists
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
    if (item.progress.status.isDownloaded && !item.entry.isFileExists) {
      return context.t.downloads.noFile;
    }

    final status = context.t.downloads.status;
    switch (item.progress.status) {
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
    final serverData = ref.watch(serverDataStateProvider);
    final headers = ref.watch(postHeadersFactoryProvider(item.entry.post));

    return ListTile(
      title: Text(
        Uri.decodeFull(item.entry.destination.fileName),
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
                if (item.progress.status.isDownloading ||
                    item.progress.status.isPending) ...[
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: CircularProgressIndicator(
                        value: item.progress.status.isPending
                            ? null
                            : item.progress.progress.ratio,
                        strokeWidth: 2.5,
                        backgroundColor: context.colorScheme.surfaceVariant,
                      ),
                    ),
                  ),
                  Text('${item.progress.progress}%'),
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
                Text(serverData.getById(item.entry.post.serverId).name),
              ],
            ),
          ],
        ),
      ),
      leading: ExtendedImage.network(
        item.entry.post.previewFile,
        headers: headers,
        width: 42,
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        fit: BoxFit.cover,
      ),
      trailing: _EntryPopupMenu(
        item: item,
        server: serverData.getById(item.entry.post.serverId),
      ),
      dense: true,
      onTap: !item.progress.status.isDownloaded || !item.entry.isFileExists
          ? null
          : () => ref.read(downloaderProvider).openFile(id: item.entry.id),
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
    required this.item,
    required this.server,
  });

  final DownloadItem item;
  final ServerData server;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
      onSelected: (value) {
        final downloader = ref.read(downloaderProvider);
        switch (value) {
          case 'redownload':
            DownloaderDialog.show(
              context,
              ref,
              item.entry.post,
              onItemClick: (type) async {
                await downloader.clear(id: item.entry.id);
              },
            );
            break;
          case 'retry':
            downloader.retry(id: item.entry.id);
            break;
          case 'cancel':
            downloader.cancel(id: item.entry.id);
            break;
          case 'clear':
            downloader.clear(id: item.entry.id);
            break;
          case 'show-detail':
            context.router.push(PostDetailsRoute(
              post: item.entry.post,
              session: ref.read(searchSessionProvider),
            ));
            break;
          default:
            break;
        }
      },
      itemBuilder: (context) {
        return [
          if (item.progress.status.isDownloaded && !item.entry.isFileExists)
            PopupMenuItem(
              value: 'redownload',
              child: Text(context.t.downloads.redownload),
            ),
          if (item.progress.status.isCanceled || item.progress.status.isFailed)
            PopupMenuItem(
              value: 'retry',
              child: Text(context.t.retry),
            ),
          if (item.progress.status.isDownloading)
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
