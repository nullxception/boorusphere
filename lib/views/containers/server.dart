import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../provider/server_data.dart';
import '../components/favicon.dart';
import 'server_add.dart';

class ServerPage extends HookConsumerWidget {
  const ServerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref.watch(serverDataProvider);

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
                      backgroundColor: Theme.of(context).colorScheme.background,
                      title: const Text('Server'),
                      content: const Text(
                        '''
Are you sure you want to reset server list to default ? \n\nThis will erase all of your added server.''',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            server.resetToDefault();
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...server.all.map((it) {
              return ListTile(
                title: Text(it.name),
                subtitle: Text(it.homepage),
                leading: Favicon(url: '${it.homepage}/favicon.ico'),
                trailing: server.all.length == 1
                    ? null
                    : IconButton(
                        onPressed: () {
                          server.removeServer(data: it);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                dense: true,
                contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                onTap: null,
              );
            }).toList(),
            ListTile(
              title: const Text('Add'),
              leading: const Icon(Icons.add),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ServerAddPage()),
              ),
            )
          ],
        ),
      ),
    );
  }
}
