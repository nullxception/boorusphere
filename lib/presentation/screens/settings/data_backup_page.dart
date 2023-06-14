import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/data_backup/data_backup.dart';
import 'package:boorusphere/presentation/provider/data_backup/entity/backup_option.dart';
import 'package:boorusphere/presentation/provider/data_backup/entity/backup_result.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage()
class DataBackupPage extends StatelessWidget {
  const DataBackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.dataBackup.title)),
      body: const SafeArea(child: _Content()),
    );
  }
}

class _Content extends HookConsumerWidget {
  const _Content();

  Future<bool?> _warningDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.t.dataBackup.restore.title),
          icon: const Icon(Icons.restore),
          content: Text(context.t.dataBackup.restore.warning),
          actions: [
            TextButton(
              onPressed: () {
                context.navigator.pop(false);
              },
              child: Text(context.t.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                context.navigator.pop(true);
              },
              child: Text(context.t.restore),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const subtitlePadding = EdgeInsets.only(top: 8);
    ref.listen<BackupResult?>(dataBackupStateProvider, (prev, next) {
      switch (next) {
        case LoadingBackupResult(:final type):
          showDialog(
            context: context,
            builder: (_) => ProviderScope(
              parent: ProviderScope.containerOf(context),
              child: _LoadingDialog(type: type),
            ),
          );
        case ImportedBackupResult():
          context.scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(context.t.dataBackup.restore.success),
            duration: const Duration(seconds: 1),
          ));
        case ExportedBackupResult(:final path):
          context.scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(context.t.dataBackup.backup.success(dest: path)),
            duration: const Duration(seconds: 2),
          ));
        case ErrorBackupResult():
          context.scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(context.t.dataBackup.restore.invalid),
            duration: const Duration(seconds: 1),
          ));
        default:
      }
    });

    return ListView(
      children: [
        ListTile(
          title: Text(context.t.dataBackup.backup.title),
          subtitle: Padding(
            padding: subtitlePadding,
            child: Text(context.t.dataBackup.backup.desc),
          ),
          onTap: () async {
            final result = await showDialog<BackupOption?>(
              context: context,
              builder: (context) => _BackupSelectionDialog(),
            );
            if (result != null) {
              unawaited(ref
                  .read(dataBackupStateProvider.notifier)
                  .backup(option: result));
            }
          },
        ),
        ListTile(
          title: Text(context.t.dataBackup.restore.title),
          subtitle: Padding(
            padding: subtitlePadding,
            child: Text(context.t.dataBackup.restore.desc),
          ),
          onTap: () {
            ref
                .read(dataBackupStateProvider.notifier)
                .restore(onConfirm: () => _warningDialog(context));
          },
        ),
      ],
    );
  }
}

class _LoadingDialog extends HookConsumerWidget {
  const _LoadingDialog({required this.type});

  final DataBackupType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(dataBackupStateProvider, (previous, next) {
      if (next is! LoadingBackupResult) {
        context.navigator.pop();
      }
    });
    return Dialog(
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
          Text(
            type == DataBackupType.backup
                ? context.t.dataBackup.backup.loading
                : context.t.dataBackup.restore.loading,
          ),
        ],
      ),
    );
  }
}

class _BackupSelectionDialog extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final option = useState(const BackupOption());
    return AlertDialog(
      title: Text(context.t.dataBackup.backup.title),
      icon: const Icon(Icons.restore),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: Text(context.t.servers.title),
            value: option.value.server,
            onChanged: (newValue) {
              option.value = option.value.copyWith(server: newValue ?? true);
            },
          ),
          CheckboxListTile(
            title: Text(context.t.searchHistory),
            value: option.value.searchHistory,
            onChanged: (newValue) {
              option.value =
                  option.value.copyWith(searchHistory: newValue ?? true);
            },
          ),
          CheckboxListTile(
            title: Text(context.t.tagsBlocker.title),
            value: option.value.blockedTags,
            onChanged: (newValue) {
              option.value =
                  option.value.copyWith(blockedTags: newValue ?? true);
            },
          ),
          CheckboxListTile(
            title: Text(context.t.favorites.title),
            value: option.value.favoritePost,
            onChanged: (newValue) {
              option.value =
                  option.value.copyWith(favoritePost: newValue ?? true);
            },
          ),
          CheckboxListTile(
            title: Text(context.t.settings.title),
            value: option.value.setting,
            onChanged: (newValue) {
              option.value = option.value.copyWith(setting: newValue ?? true);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.navigator.pop();
          },
          child: Text(context.t.cancel),
        ),
        ElevatedButton(
          onPressed: option.value.isValid()
              ? () {
                  final result = option.value;
                  context.navigator.pop(result);
                }
              : null,
          child: Text(context.t.backup),
        )
      ],
    );
  }
}
