import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../entity/download_entry.dart';
import '../../services/download.dart';
import '../../settings/download/group_by_server.dart';
import '../../widgets/expandable_group_list_view.dart';
import '../../widgets/notice_card.dart';
import 'download_entry_view.dart';

class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloader = ref.watch(downloadProvider);
    final groupByServer = ref.watch(groupByServerProvider);

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
                    ref
                        .read(groupByServerProvider.notifier)
                        .enable(!groupByServer);
                    break;
                  default:
                    break;
                }
              },
              itemBuilder: (context) {
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
      body: SafeArea(
        child: downloader.entries.isEmpty
            ? Column(
                children: const [
                  Center(
                    child: NoticeCard(
                      icon: Icon(Icons.cloud_download),
                      margin: EdgeInsets.only(top: 64),
                      children: Text('Your downloaded files will appear here'),
                    ),
                  ),
                ],
              )
            : ExpandableGroupListView<DownloadEntry, String>(
                items: downloader.entries.reversed.toList(),
                groupedBy: (entry) => entry.post.serverName,
                groupTitle: Text.new,
                itemBuilder: (entry) => DownloadEntryView(entry: entry),
                ungroup: !groupByServer,
              ),
      ),
    );
  }
}
