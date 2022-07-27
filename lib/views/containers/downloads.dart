import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:separated_row/separated_row.dart';

import '../../model/download_entry.dart';
import '../../model/download_status.dart';
import '../../provider/downloader.dart';
import '../../provider/settings/downloads/group_by_server.dart';
import '../components/expandable_group_list_view.dart';
import '../components/notice_card.dart';
import 'post_detail.dart';

class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloader = ref.watch(downloadProvider);
    final groupByServer = ref.watch(groupByServerProvider);
    final groupByServerNotifier = ref.watch(groupByServerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          if (downloader.entries.isNotEmpty)
            PopupMenuButton(
              onSelected: (value) {
                switch (value) {
                  case 'clear-all':
                    downloader.clearEntries();
                    break;
                  case 'group-by-server':
                    groupByServerNotifier.enable(!groupByServer);
                    break;
                  default:
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 'group-by-server',
                    child: Text(groupByServer ? 'Ungroup' : 'Group by server'),
                  ),
                  const PopupMenuItem(
                    value: 'clear-all',
                    child: Text('Clear all'),
                  ),
                ];
              },
            )
        ],
      ),
      body: downloader.entries.isEmpty
          ? _DownloadPagePlaceholder()
          : _DownloadList(),
    );
  }
}

class _DownloadEntryPopupMenu extends ConsumerWidget {
  const _DownloadEntryPopupMenu({required this.entry});

  final DownloadEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloader = ref.watch(downloadProvider);
    final progress = downloader.getProgress(entry.id);

    return PopupMenuButton(
      onSelected: (value) {
        switch (value) {
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

class _DownloadPagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Center(
          child: NoticeCard(
            icon: Icon(Icons.cloud_download),
            margin: EdgeInsets.only(top: 64),
            children: Text('Your downloaded files will appear here'),
          ),
        ),
      ],
    );
  }
}

class _DownloadList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloader = ref.watch(downloadProvider);
    final groupByServer = ref.watch(groupByServerProvider);
    final entries = downloader.entries.reversed.toList();

    return ExpandableGroupListView<DownloadEntry, String>(
      items: entries,
      groupedBy: (entry) => entry.post.serverName,
      groupTitle: (key) => Text(key),
      itemBuilder: (entry) => _DownloadEntryView(entry: entry),
      ungroup: !groupByServer,
    );
  }
}

class _DownloadEntryView extends ConsumerWidget {
  const _DownloadEntryView({required this.entry});

  final DownloadEntry entry;

  IconData downloadStatusIconOf(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.downloaded:
        return Icons.download_done_rounded;
      case DownloadStatus.downloading:
        return Icons.downloading_rounded;
      case DownloadStatus.canceled:
      case DownloadStatus.failed:
        return Icons.cancel_rounded;
      default:
        return Icons.file_open;
    }
  }

  Color downloadStatusColorOf(DownloadStatus status, ColorScheme scheme) {
    switch (status) {
      case DownloadStatus.downloaded:
        return Colors.lightBlueAccent;
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
            if (progress.status.isDownloading) ...[
              SizedBox(
                height: 18,
                width: 18,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: CircularProgressIndicator(
                    value: (1 * progress.progress) / 100,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
              Text('${progress.progress}%'),
            ] else
              Icon(
                downloadStatusIconOf(progress.status),
                color: downloadStatusColorOf(
                    progress.status, Theme.of(context).colorScheme),
                size: 18,
              ),
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
      trailing: _DownloadEntryPopupMenu(entry: entry),
      dense: true,
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      onTap: !progress.status.isDownloaded
          ? null
          : () => downloader.openEntryFile(id: entry.id),
    );
  }
}
