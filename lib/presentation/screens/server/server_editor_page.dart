import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/booru/provider.dart';
import 'package:boorusphere/data/repository/booru/utils/booru_scanner.dart';
import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:boorusphere/presentation/screens/server/server_details.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/widgets/error_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage()
class ServerEditorPage extends StatelessWidget {
  const ServerEditorPage({super.key, this.server = Server.empty});

  final Server server;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          server != Server.empty
              ? context.t.servers.edit(name: server.name)
              : context.t.servers.add,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: _ServerEditor(server: server),
        ),
      ),
    );
  }
}

class _ServerEditor extends HookConsumerWidget {
  const _ServerEditor({Server server = Server.empty}) : _server = server;

  final Server _server;

  bool get isEditing => _server != Server.empty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final imeIncognito =
        ref.watch(uiSettingStateProvider.select((it) => it.imeIncognito));
    final server = useState(_server);
    final useApiAddr = useState(_server.apiAddr.isNotEmpty);
    final homepage = useTextEditingController(
        text: isEditing ? _server.homepage : 'https://');
    final apiAddr = useTextEditingController(
        text: _server.apiAddr.isEmpty ? 'https://' : _server.apiAddr);

    validateAddress(String? value) {
      if (value?.contains(RegExp(r'https?://.+\..+')) == false) {
        return context.t.servers.addrError;
      }

      return null;
    }

    return Column(
      children: [
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: TextFormField(
                  controller: homepage,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: context.t.servers.homepageHint,
                  ),
                  validator: validateAddress,
                ),
              ),
              CheckboxListTile(
                value: useApiAddr.value,
                title: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(context.t.servers.useCustomApi),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(context.t.servers.useCustomApiDesc),
                ),
                onChanged: (isChecked) {
                  if (isChecked != null) {
                    useApiAddr.value = isChecked;
                  }
                },
              ),
              if (useApiAddr.value)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: TextFormField(
                    controller: apiAddr,
                    enableIMEPersonalizedLearning: !imeIncognito,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: context.t.servers.apiAddrHint,
                    ),
                    validator: validateAddress,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() != true) {
                      return;
                    }

                    FocusScope.of(context).unfocus();
                    final baseServer = server.value.copyWith(
                      homepage: homepage.text,
                      apiAddr: useApiAddr.value ? apiAddr.text : '',
                    );
                    final result =
                        await ScannerDialog.open(context, baseServer);
                    if (result.searchParserId.isNotEmpty) {
                      server.value = result;
                    }
                    if (result.apiAddr.isNotEmpty) {
                      useApiAddr.value = true;
                      apiAddr.text = result.apiAddr;
                    }
                  },
                  child: Text(context.t.scan),
                ),
              ),
            ],
          ),
        ),
        ServerDetails(
          server: server.value,
          isEditing: isEditing,
          onSubmitted: (newServer) {
            final serverPod = ref.read(serverStateProvider.notifier);
            newServer = newServer.copyWith(
              homepage: homepage.text,
              apiAddr: useApiAddr.value ? apiAddr.text : '',
            );

            if (isEditing) {
              serverPod.edit(_server, newServer);
            } else {
              serverPod.add(newServer);
            }

            context.router.maybePop();
          },
        ),
      ],
    );
  }
}

class ScannerDialog extends HookConsumerWidget {
  const ScannerDialog({
    super.key,
    required this.server,
  });

  final Server server;
  static Future<Server> open(BuildContext context, Server server) async {
    final result = context.navigator.push<Server>(
      DialogRoute(
        context: context,
        builder: (context) => ScannerDialog(server: server),
      ),
    );
    return await result ?? server;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dio = ref.watch(dioProvider);
    final parsers = ref.watch(booruParsersProvider);
    final scanner = useBooruScanner(dio, parsers);
    final logs = useValueListenable(scanner.logs);
    final result = useState(server);
    final isScanning = useValueListenable(scanner.isScanning);
    final error = useState<Object?>(null);

    useEffect(() {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
        try {
          final unparsedErr = context.t.servers.incompatible;
          final newServer = await scanner.scan(server);
          if (newServer.searchParserId.isNotEmpty) {
            result.value = newServer;
          } else {
            error.value = unparsedErr(addr: server.apiAddress);
          }
        } catch (e) {
          if (e is DioException && e.type == DioExceptionType.cancel) {
            return;
          }
          error.value = e;
        }
      });
    }, []);

    return Card(
      margin: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...logs.map(
                      (e) => Text(
                        e,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Colors.greenAccent,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (error.value != null)
                Container(
                  color: context.colorScheme.error,
                  padding: const EdgeInsets.all(16),
                  child: ErrorInfo(
                    error: error.value,
                    style: TextStyle(color: context.colorScheme.onError),
                    padding: EdgeInsets.zero,
                  ),
                ),
              if (isScanning)
                const LinearProgressIndicator(
                    backgroundColor: Colors.transparent),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () async {
                    if (!isScanning) {
                      context.navigator.pop(result.value);
                      return;
                    }

                    context.navigator.pop();
                    unawaited(scanner.stop());
                  },
                  child: Text(
                    isScanning ? context.t.cancel : context.t.actionContinue,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
