import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/presentation/routes/routes.dart';
import 'package:boorusphere/presentation/widgets/favicon.dart';
import 'package:boorusphere/source/server.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
                            ref.read(serverDataProvider.notifier).reset();
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
            itemBuilder: (context) {
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
                  leading: Favicon(url: it.homepage),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          context.router.push(ServerEditorRoute(server: it));
                          break;
                        case 'remove':
                          if (serverData.length == 1) {
                            context.scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                    duration: Duration(seconds: 1),
                                    content: Text(
                                        'The last server cannot be removed')));
                            break;
                          }

                          ref
                              .read(serverDataProvider.notifier)
                              .delete(data: it);
                          break;
                        default:
                          break;
                      }
                    },
                    itemBuilder: (context) {
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
                );
              }).toList(),
              ListTile(
                title: const Text('Add'),
                leading: const Icon(Icons.add),
                onTap: () => context.router.push(ServerEditorRoute()),
              )
            ],
          ),
        ),
      ),
    );
  }
}
