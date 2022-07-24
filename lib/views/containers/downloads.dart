import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/download_entry.dart';
import '../../provider/downloader.dart';
import '../components/notice_card.dart';
import 'post_detail.dart';

class DownloadsPage extends HookConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloader = ref.watch(downloadProvider);

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
                  default:
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem(
                    value: 'clear-all',
                    child: Text('Clear all'),
                  )
                ];
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (downloader.entries.isEmpty)
              const Center(
                child: NoticeCard(
                  icon: Icon(Icons.cloud_download),
                  margin: EdgeInsets.only(top: 64),
                  children: Text('Your downloaded files will appear here'),
                ),
              ),
            ...downloader.entries.reversed.map((it) {
              final fileName =
                  Uri.decodeFull(downloader.getFileNameFromUrl(it.destination));
              final progress = downloader.getProgress(it.id);

              return ListTile(
                title: Text(
                  fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    progress.status.isDownloading
                        ? '${progress.status.name} ${progress.progress}% • ${it.booru.serverName}'
                        : '${progress.status.name} • ${it.booru.serverName}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                leading: ExtendedImage.network(
                  it.booru.previewFile,
                  width: 42,
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  fit: BoxFit.cover,
                ),
                trailing: _DownloadEntryPopupMenu(entry: it),
                dense: true,
                contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                onTap: !progress.status.isDownloaded
                    ? null
                    : () => downloader.openEntryFile(id: it.id),
              );
            }).toList(),
          ],
        ),
      ),
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
