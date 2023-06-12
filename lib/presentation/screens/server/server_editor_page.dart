import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/booru/utils/booru_scanner.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:boorusphere/presentation/screens/server/server_details.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/widgets/error_info.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage()
class ServerEditorPage extends StatelessWidget {
  const ServerEditorPage({super.key, this.server = ServerData.empty});

  final ServerData server;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          server != ServerData.empty
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

  final ServerData server;

  bool get isEditing => server != ServerData.empty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dio = ref.watch(dioProvider);
    final scanner = useMemoized(() => BooruScanner(dio), [dio]);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final imeIncognito =
        ref.watch(uiSettingStateProvider.select((it) => it.imeIncognito));
    final data = useState(server);
    final isScanning = useState(false);
    final useApiAddr = useState(false);
    final error = useState<Object?>(null);
    final scanHomepageText = useTextEditingController(
        text: isEditing ? server.homepage : 'https://');
    final scanApiAddrText =
        useTextEditingController(text: isEditing ? server.apiAddr : 'https://');

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
              controller: scanHomepageText,
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
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: TextFormField(
                controller: scanApiAddrText,
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
                if (isScanning.value) {
                  await scanner.stop();
                  isScanning.value = false;
                  return;
                }

                data.value = ServerData.empty;
                isScanning.value = true;
                error.value = null;
                final homeAddr = scanHomepageText.text;
                final apiAddr =
                    useApiAddr.value ? scanApiAddrText.text : homeAddr;
                try {
                  final scan = scanner.scan(homeAddr, apiAddr);
                  await for (var ev in scan) {
                    data.value = ev;
                  }
                } catch (e) {
                  if (e is DioException && e.type == DioExceptionType.cancel) {
                    isScanning.value = false;
                    return;
                  }

                  error.value = e;
                  data.value = ServerData.empty.copyWith(
                    id: homeAddr.toUri().host,
                    homepage: homeAddr,
                  );
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
                    data: data.value,
                    isEditing: isEditing,
                    onSubmitted: (data) {
                      final serverDataNotifier =
                          ref.read(serverDataStateProvider.notifier);

                      if (isEditing) {
                        serverDataNotifier.edit(server, data);
                      } else {
                        serverDataNotifier.add(data);
                      }
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
