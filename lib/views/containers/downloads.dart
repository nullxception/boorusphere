import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/download_entry.dart';
import '../../provider/downloader.dart';
import '../../provider/settings/downloads/group_by_server.dart';
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
                  builder: (context) => PostDetailsPage(booru: entry.booru)),
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
    return const Center(
      child: NoticeCard(
        icon: Icon(Icons.cloud_download),
        margin: EdgeInsets.only(top: 64),
        children: Text('Your downloaded files will appear here'),
      ),
    );
  }
}

class _DownloadList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloader = ref.watch(downloadProvider);
    final groupByServer = ref.watch(groupByServerProvider);
    final entries = downloader.entries.reversed.toList();

    return groupByServer
        ? GroupedListView<DownloadEntry, String>(
            elements: entries,
            padding: const EdgeInsets.only(bottom: 48),
            groupBy: (entry) => entry.booru.serverName,
            groupSeparatorBuilder: (serverName) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  serverName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              );
            },
            itemBuilder: (context, entry) {
              return _DownloadEntryView(entry: entry);
            },
          )
        : ListView.builder(
            padding: const EdgeInsets.only(bottom: 48),
            itemCount: entries.length,
            itemBuilder: (context, id) {
              return _DownloadEntryView(entry: entries[id]);
            },
          );
  }
}

class _DownloadEntryView extends ConsumerWidget {
  const _DownloadEntryView({required this.entry});

  final DownloadEntry entry;

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
        child: Text(
          [
            if (progress.status.isDownloading) '${progress.progress}%',
            progress.status.name,
            if (!groupByServer) '• ${entry.booru.serverName}',
          ].join(' '),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      leading: ExtendedImage.network(
        entry.booru.previewFile,
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
