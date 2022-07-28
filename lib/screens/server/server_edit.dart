import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/server_data.dart';
import '../../../providers/server_data.dart';
import '../../../providers/server_scanner.dart';
import '../../../widgets/server_details.dart';

class ServerEditorPage extends HookConsumerWidget {
  const ServerEditorPage({super.key, this.server = ServerData.empty});

  final ServerData server;

  bool get isEditing => server != ServerData.empty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverScanner = ref.watch(serverScannerProvider);
    final serverData = ref.watch(serverDataProvider);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final data = useState(server);
    final isLoading = useState(false);
    final errorMessage = useState('');
    final scanText = useTextEditingController(
        text: isEditing ? server.homepage : 'https://');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit ${server.name}' : 'Add new server'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: TextFormField(
                  controller: scanText,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Example: https://abc.com',
                  ),
                  validator: (value) {
                    final homescreens = serverData.map((it) => it.homepage);
                    if (!isEditing && homescreens.contains(value)) {
                      return 'Server data for $value already exists';
                    }
                    if (value?.contains(RegExp(r'https?://.+\..+')) == false) {
                      return 'not a valid url';
                    }

                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: !isLoading.value
                      ? () async {
                          if (formKey.currentState?.validate() != true) {
                            return;
                          }

                          FocusScope.of(context).unfocus();
                          data.value = ServerData.empty;
                          isLoading.value = true;
                          errorMessage.value = '';
                          try {
                            final res = await serverScanner.scan(scanText.text);
                            data.value = res;
                          } catch (e) {
                            errorMessage.value = e.toString();
                            data.value = ServerData.empty.copyWith(
                              name: Uri.parse(scanText.text).host,
                              homepage: scanText.text,
                            );
                          }

                          isLoading.value = false;
                        }
                      : null,
                  child: const Text('Scan'),
                ),
              ),
              Visibility(
                visible: isLoading.value,
                child: Container(
                  height: 64,
                  alignment: Alignment.center,
                  child: SpinKitThreeBounce(
                      size: 32, color: Theme.of(context).colorScheme.primary),
                ),
              ),
              if (errorMessage.value.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  color: Theme.of(context).colorScheme.error,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    errorMessage.value,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.onError),
                  ),
                ),
              if (data.value.name.isNotEmpty)
                ServerDetails(
                  data: data.value,
                  isEditing: isEditing,
                  onSubmitted: (data) {
                    final serverDataNotifier =
                        ref.read(serverDataProvider.notifier);

                    if (isEditing) {
                      serverDataNotifier.editServer(
                          data: server, newData: data);
                    } else {
                      serverDataNotifier.addServer(data: data);
                    }
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
