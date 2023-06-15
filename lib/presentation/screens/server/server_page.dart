import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:boorusphere/presentation/routes/app_router.gr.dart';
import 'package:boorusphere/presentation/screens/home/search_session.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/widgets/favicon.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage()
class ServerPage extends ConsumerWidget {
  const ServerPage({super.key, this.session});
  final SearchSession? session;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedServerId =
        ref.read(serverSettingStateProvider.select((it) => it.lastActiveId));
    final session = this.session ?? SearchSession(serverId: savedServerId);

    return ProviderScope(
      overrides: [
        searchSessionProvider.overrideWith((ref) => session),
      ],
      child: const _Content(),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serverStateProvider);

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
                            ref.read(serverStateProvider.notifier).reset();
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
              ...servers.map((it) {
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
                          if (servers.length == 1) {
                            context.scaffoldMessenger.showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 1),
                                content:
                                    Text(context.t.servers.removeLastError),
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
