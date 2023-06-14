import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/booru/provider.dart';
import 'package:boorusphere/data/repository/booru/utils/booru_scanner.dart';
import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:boorusphere/data/repository/server/entity/server_auth.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/server_auth_state.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:boorusphere/presentation/screens/server/server_details.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/widgets/error_info.dart';
import 'package:boorusphere/presentation/widgets/private_text_field.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
  const _ServerEditor({required this.server});

  final Server server;

  bool get isEditing => server != Server.empty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dio = ref.watch(dioProvider);
    final parsers = ref.watch(booruParsersProvider);
    final scanner = useBooruScanner(dio, parsers);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final imeIncognito =
        ref.watch(uiSettingStateProvider.select((it) => it.imeIncognito));
    final newServer = useState(server);
    final isScanning = useState(false);
    final useApiAddr = useState(false);
    final error = useState<Object?>(null);
    final homepage = useTextEditingController(
        text: isEditing ? server.homepage : 'https://');
    final apiAddress = useTextEditingController(
        text: server.apiAddr.isEmpty ? 'https://' : server.apiAddr);

    final auth = ref.watch(serverAuthStateProvider).on(server);
    final userId =
        useTextEditingController(text: isEditing ? auth.userId : null);
    final userKey =
        useTextEditingController(text: isEditing ? auth.userKey : null);
    final newServerAuth = useState(auth);

    validateAddress(String? value) {
      if (value?.contains(RegExp(r'https?://.+\..+')) == false) {
        return context.t.servers.addrError;
      }

      return null;
    }

    return Form(
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
                controller: apiAddress,
                enableIMEPersonalizedLearning: !imeIncognito,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: context.t.servers.apiAddrHint,
                ),
                validator: validateAddress,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Authorization',
              style: context.theme.textTheme.titleSmall
                  ?.copyWith(color: context.colorScheme.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: TextFormField(
              controller: userId,
              enableIMEPersonalizedLearning: !imeIncognito,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                labelText: context.t.servers.userId,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: PrivateTextField(
              controller: userKey,
              imeIncognito: imeIncognito,
              label: context.t.servers.userKey,
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
                if (isScanning.value) {
                  await scanner.stop();
                  isScanning.value = false;
                  return;
                }

                isScanning.value = true;
                error.value = null;
                final home = homepage.text;
                final api = useApiAddr.value ? apiAddress.text : home;
                try {
                  final auth =
                      ServerAuth(userId: userId.text, userKey: userKey.text);
                  newServer.value = await scanner.scan(home, api);
                } catch (e) {
                  if (e is DioException && e.type == DioExceptionType.cancel) {
                    isScanning.value = false;
                    return;
                  }

                  error.value = e;
                  newServer.value = newServer.value.copyWith(homepage: home);
                  if (newServer.value.id.isEmpty) {
                    newServer.value =
                        newServer.value.copyWith(id: home.toUri().host);
                  }
                }

                isScanning.value = false;
              },
              child: Text(isScanning.value ? context.t.cancel : context.t.scan),
            ),
          ),
          if (error.value != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              color: context.colorScheme.error,
              padding: const EdgeInsets.all(16),
              child: ErrorInfo(
                error: error.value,
                style: TextStyle(color: context.colorScheme.onError),
                padding: EdgeInsets.zero,
              ),
            ),
          Stack(
            children: [
              IgnorePointer(
                ignoring: isScanning.value,
                child: Opacity(
                  opacity: isScanning.value ? 0.25 : 1,
                  child: ServerDetails(
                    server: newServer.value,
                    isEditing: isEditing,
                    onSubmitted: (data) {
                      final serverPod = ref.read(serverStateProvider.notifier);

                      if (isEditing) {
                        serverPod.edit(server, data);
                      } else {
                        serverPod.add(data);
                      }

                      ref.read(serverAuthStateProvider.notifier).update(
                          newServerAuth.value.copyWith(
                              serverId: data.id,
                              userId: userId.text,
                              userKey: userKey.text));

                      context.router.pop();
                    },
                  ),
                ),
              ),
              if (isScanning.value) ScannerLog(scanner: scanner)
            ],
          ),
        ],
      ),
    );
  }
}

class ScannerLog extends HookWidget {
  const ScannerLog({
    super.key,
    required this.scanner,
  });

  final BooruScanner scanner;

  @override
  Widget build(BuildContext context) {
    final logs = useStream(scanner.logs);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.black,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...?logs.data?.map(
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
          const LinearProgressIndicator(
            backgroundColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
}
