import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/server_data.dart';
import '../../provider/booru_api.dart';
import '../components/server_scanner.dart';

class ServerAddPage extends HookConsumerWidget {
  const ServerAddPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(booruApiProvider);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final data = useState(ServerData.empty);
    final isLoading = useState(false);
    final errorMessage = useState('');
    final scanText = useTextEditingController(text: 'https://');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new server'),
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
                          final res = await api.scanServerUrl(scanText.text);
                          res.fold((l) {
                            errorMessage.value = l.toString();
                            data.value = ServerData.empty.copyWith(
                              name: Uri.parse(scanText.text).host,
                              homepage: scanText.text,
                            );
                          }, (r) {
                            data.value = r;
                          });
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
              if (data.value.name.isNotEmpty) ServerScanner(data: data.value),
            ],
          ),
        ),
      ),
    );
  }
}
