import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/routes/app_router.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/widgets/favicon.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ServerPage extends ConsumerWidget {
  const ServerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverData = ref.watch(serverDataStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.servers.title),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 'reset':
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(context.t.resetToDefault),
                      icon: const Icon(Icons.restore),
                      content: Text(context.t.servers.resetWarning),
                      actions: [
                        TextButton(
                          onPressed: () {
                            context.navigator.pop();
                          },
                          child: Text(context.t.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.navigator.pop();
                            ref.read(serverDataStateProvider.notifier).reset();
                          },
                          child: Text(context.t.reset),
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
                  child: Text(context.t.resetToDefault),
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
                                content:
                                    Text(context.t.servers.removeLastError),
                              ),
                            );
                            break;
                          }

                          ref.read(serverDataStateProvider.notifier).remove(it);
                          break;
                        default:
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(context.t.edit),
                        ),
                        PopupMenuItem(
                          value: 'remove',
                          child: Text(context.t.remove),
                        ),
                      ];
                    },
                  ),
                  dense: true,
                );
              }).toList(),
              ListTile(
                title: Text(context.t.add),
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
