import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/data_backup/data_backup.dart';
import 'package:boorusphere/presentation/provider/data_backup/entity/backup_result.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
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
            ref.read(dataBackupStateProvider.notifier).export();
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
