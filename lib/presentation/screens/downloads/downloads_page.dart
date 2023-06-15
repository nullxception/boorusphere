import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_entry.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/download/download_state.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/download_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:boorusphere/presentation/screens/downloads/download_entry_view.dart';
import 'package:boorusphere/presentation/screens/downloads/download_filter.dart';
import 'package:boorusphere/presentation/screens/home/search_session.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/widgets/expandable_group_list_view.dart';
import 'package:boorusphere/presentation/widgets/notice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage()
class DownloadsPage extends HookConsumerWidget {
  const DownloadsPage({super.key, this.session});
  final SearchSession? session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedServerId =
        ref.read(serverSettingStateProvider.select((it) => it.lastActiveId));
    final session = this.session ?? SearchSession(serverId: savedServerId);
    final servers = ref.watch(serverStateProvider);
    final downloadEntries =
        ref.watch(downloadEntryStateProvider).whereNotReserved();
    final downloadProgressState = ref.watch(downloadProgressStateProvider);
    final groupByServer = ref
        .watch(downloadSettingStateProvider.select((it) => it.groupByServer));
    final filter = useState(DownloadFilter.none);
    var filteredEntries = downloadEntries;
    if (filter.value != DownloadFilter.none) {
      filteredEntries = downloadEntries.where((it) =>
          downloadProgressState.getById(it.id).status ==
          filter.value.toStatus());
    }

    return ProviderScope(
      overrides: [searchSessionProvider.overrideWith((ref) => session)],
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.t.downloads.title),
          actions: [
            if (downloadEntries.isNotEmpty)
              PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 'filter':
                      showFilterDialog(context, filter.value).then((value) {
                        if (value != null) {
                          filter.value = value;
                        }
                      });
                      break;
                    case 'clear-all':
                      showClearDialog(context).then((value) {
                        if (value ?? false) {
                          ref.read(downloadEntryStateProvider.notifier).clear();
                        }
                      });
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
                      value: 'filter',
                      child: Text(context.t.downloads.filterByStatus),
                    ),
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
                      child: Text(context.t.downloads.clearAll),
                    ),
                  ];
                },
              )
          ],
        ),
        body: SafeArea(
          child: filteredEntries.isEmpty
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
                  items: filteredEntries,
                  groupedBy: (item) => item.post.serverId,
                  groupTitle: (id) => Text(servers.getById(id).name),
                  itemBuilder: (item) => DownloadEntryView(
                    entry: item,
                    groupByServer: groupByServer,
                  ),
                  ungroup: !groupByServer,
                ),
        ),
      ),
    );
  }

  Future<DownloadFilter?> showFilterDialog(
    BuildContext context,
    DownloadFilter current,
  ) {
    return showDialog<DownloadFilter?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.t.downloads.filterByStatus),
          icon: const Icon(Icons.file_download),
          contentPadding: const EdgeInsets.only(top: 16, bottom: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: DownloadFilter.values
                .map((e) => RadioListTile(
                      value: e,
                      groupValue: current,
                      title: Text(e.describe(context)),
                      onChanged: (value) {
                        context.navigator.pop(value);
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  Future<bool?> showClearDialog(BuildContext context) {
    return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.t.downloads.clearAll),
          icon: const Icon(Icons.delete_forever),
          content: Text(context.t.downloads.clearAllWarning),
          actions: [
            TextButton(
              onPressed: () {
                context.navigator.pop();
              },
              child: Text(context.t.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                context.navigator.pop(true);
              },
              child: Text(context.t.clear),
            ),
          ],
        );
      },
    );
  }
}
