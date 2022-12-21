import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/data_backup/data_backup.dart';
import 'package:boorusphere/presentation/provider/data_backup/entity/backup_option.dart';
import 'package:boorusphere/presentation/provider/data_backup/entity/backup_result.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

class _Content extends ConsumerWidget {
  const _Content();

  Future<bool?> _warningDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.colorScheme.background,
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
      next?.maybeWhen(
        imported: () {
          context.scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(context.t.dataBackup.restore.success),
            duration: const Duration(seconds: 1),
          ));
        },
        exported: (data) {
          context.scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(context.t.dataBackup.backup.success(dest: data)),
            duration: const Duration(seconds: 2),
          ));
        },
        error: (error, stackTrace) {
          context.scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(context.t.dataBackup.restore.invalid),
            duration: const Duration(seconds: 1),
          ));
        },
        orElse: () {},
      );
    });

    return ListView(
      children: [
        ListTile(
          title: Text(context.t.dataBackup.backup.title),
          subtitle: Padding(
            padding: subtitlePadding,
            child: Text(context.t.dataBackup.backup.desc),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return _BackupSelectionDialog(
                  onBackup: (option) {
                    ref
                        .read(dataBackupStateProvider.notifier)
                        .export(option: option);
                  },
                );
              },
            );
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
                .import(onConfirm: () => _warningDialog(context));
          },
        ),
      ],
    );
  }
}

class _BackupSelectionDialog extends HookWidget {
  const _BackupSelectionDialog({required this.onBackup});
  final void Function(BackupOption option) onBackup;

  @override
  Widget build(BuildContext context) {
    final option = useState(const BackupOption());
    return AlertDialog(
      backgroundColor: context.colorScheme.background,
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
                  context.navigator.pop();
                  onBackup(option.value);
                }
              : null,
          child: Text(context.t.backup),
        )
      ],
    );
  }
}
