import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/server.dart';
import 'package:boorusphere/presentation/routes/routes.dart';
import 'package:boorusphere/presentation/widgets/favicon.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ServerPage extends HookConsumerWidget {
  const ServerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverData = ref.watch(serverStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.servers.title),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 'reset':
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: context.colorScheme.background,
                      title: Text(t.reset2),
                      icon: const Icon(Icons.restore),
                      content: Text(t.servers.resetWarning),
                      actions: [
                        TextButton(
                          onPressed: () {
                            context.navigator.pop();
                          },
                          child: Text(t.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.navigator.pop();
                            ref.read(serverStateProvider.notifier).reset();
                          },
                          child: Text(t.reset),
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
                PopupMenuItem(
                  value: 'reset',
                  child: Text(t.reset2),
                ),
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
                              SnackBar(
                                duration: const Duration(seconds: 1),
                                content: Text(t.servers.removeLastError),
                              ),
                            );
                            break;
                          }

                          ref.read(serverStateProvider.notifier).remove(it);
                          break;
                        default:
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(t.edit),
                        ),
                        PopupMenuItem(
                          value: 'remove',
                          child: Text(t.remove),
                        ),
                      ];
                    },
                  ),
                  dense: true,
                );
              }).toList(),
              ListTile(
                title: Text(t.add),
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
