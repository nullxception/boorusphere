import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/download/download_state.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/download_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:boorusphere/presentation/screens/downloads/download_entry_view.dart';
import 'package:boorusphere/presentation/screens/home/page_args.dart';
import 'package:boorusphere/presentation/widgets/expandable_group_list_view.dart';
import 'package:boorusphere/presentation/widgets/notice_card.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key, this.args});
  final PageArgs? args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedServer =
        ref.read(serverSettingStateProvider.select((it) => it.active));
    final pageArgs = args ?? PageArgs(serverId: savedServer.id);
    final serverData = ref.watch(serverDataStateProvider);
    final downloadState = ref.watch(downloadStateProvider);
    final groupByServer = ref
        .watch(downloadSettingStateProvider.select((it) => it.groupByServer));

    return ProviderScope(
      overrides: [pageArgsProvider.overrideWith((ref) => pageArgs)],
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.t.downloads.title),
          actions: [
            if (downloadState.entries.isNotEmpty)
              PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 'clear-all':
                      ref.read(downloadStateProvider.notifier).clear();
                      break;
                    case 'group-by-server':
                      ref
                          .read(downloadSettingStateProvider.notifier)
                          .setGroupByServer(!groupByServer);
                      break;
                    default:
                      break;
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 'group-by-server',
                      child: Text(
                        groupByServer
                            ? context.t.downloads.ungroup
                            : context.t.downloads.groupByServer,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'clear-all',
                      child: Text(context.t.clear),
                    ),
                  ];
                },
              )
          ],
        ),
        body: SafeArea(
          child: downloadState.entries.isEmpty
              ? Column(
                  children: [
                    Center(
                      child: NoticeCard(
                        icon: const Icon(Icons.cloud_download),
                        margin: const EdgeInsets.only(top: 64),
                        children: Text(context.t.downloads.placeholder),
                      ),
                    ),
                  ],
                )
              : ExpandableGroupListView<DownloadEntry, String>(
                  items: downloadState.entries.reversed.toList(),
                  groupedBy: (entry) => entry.post.serverId,
                  groupTitle: (id) => Text(serverData.getById(id).name),
                  itemBuilder: (entry) => DownloadEntryView(
                    entry: entry,
                    progress: downloadState.getProgressById(entry.id),
                    groupByServer: groupByServer,
                  ),
                  ungroup: !groupByServer,
                ),
        ),
      ),
    );
  }
}
