import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../widgets/favicon.dart';
import '../../source/server.dart';
import '../../utils/extensions/buildcontext.dart';
import 'server_edit.dart';

class ServerPage extends HookConsumerWidget {
  const ServerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverData = ref.watch(serverDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Server'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 'reset':
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: context.colorScheme.background,
                      title: const Text('Server'),
                      content: const Text(
                        '''
Are you sure you want to reset server list to default ? \n\nThis will erase all of your added server.''',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            context.navigator.pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.navigator.pop();
                            ref
                                .read(serverDataProvider.notifier)
                                .resetToDefault();
                          },
                          child: const Text('Reset'),
                        )
                      ],
                    ),
                  );
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'reset',
                  child: Text('Reset to default'),
                )
              ];
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...serverData.map((it) {
                return ListTile(
                  title: Text(it.name),
                  subtitle: Text(it.homepage),
                  leading: Favicon(url: '${it.homepage}/favicon.ico'),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          context.navigator.push(MaterialPageRoute(
                              builder: (context) =>
                                  ServerEditorPage(server: it)));
                          break;
                        case 'remove':
                          if (serverData.length == 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    duration: Duration(seconds: 1),
                                    content: Text(
                                        'The last server cannot be removed')));
                            break;
                          }

                          ref
                              .read(serverDataProvider.notifier)
                              .removeServer(data: it);
                          break;
                        default:
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'remove',
                          child: Text('Remove'),
                        ),
                      ];
                    },
                  ),
                  dense: true,
                  contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  onTap: null,
                );
              }).toList(),
              ListTile(
                title: const Text('Add'),
                leading: const Icon(Icons.add),
                onTap: () => context.navigator.push(
                  MaterialPageRoute(
                      builder: (context) => const ServerEditorPage()),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
