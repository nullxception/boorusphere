import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/data/provider/dio.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/presentation/provider/server.dart';
import 'package:boorusphere/presentation/screens/server/server_details.dart';
import 'package:boorusphere/presentation/widgets/exception_info.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:boorusphere/utils/server/scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ServerEditorPage extends HookConsumerWidget {
  const ServerEditorPage({super.key, this.server = ServerData.empty});

  final ServerData server;

  bool get isEditing => server != ServerData.empty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final data = useState(server);
    final isLoading = useState(false);
    final useApiAddr = useState(false);
    final error = useState<Object?>(null);
    final scanHomepageText = useTextEditingController(
        text: isEditing ? server.homepage : 'https://');
    final scanApiAddrText =
        useTextEditingController(text: isEditing ? server.apiAddr : 'https://');

    validateAddress(String? value) {
      if (value?.contains(RegExp(r'https?://.+\..+')) == false) {
        return 'not a valid address';
      }

      return null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit ${server.name}' : 'Add new server'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: TextFormField(
                    controller: scanHomepageText,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Homepage, example: https://verycoolbooru.com',
                    ),
                    validator: validateAddress,
                  ),
                ),
                CheckboxListTile(
                  value: useApiAddr.value,
                  title: const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Use custom API address')),
                  subtitle: const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                        'Useful if server has different API address than the homepage'),
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
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText:
                            'API address, example: https://api-v69.verycoolbooru.com',
                      ),
                      validator: validateAddress,
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
                            error.value = null;
                            final homeAddr = scanHomepageText.text;
                            final apiAddr = useApiAddr.value
                                ? scanApiAddrText.text
                                : homeAddr;
                            try {
                              final res = await ServerScanner.scan(
                                ref.read(dioProvider),
                                homeAddr,
                                apiAddr,
                              );
                              data.value = res.apiAddr == res.homepage
                                  ? res.copyWith(apiAddr: '')
                                  : res;
                            } catch (e) {
                              error.value = e;
                              data.value = ServerData.empty.copyWith(
                                id: homeAddr.asUri.host,
                                homepage: homeAddr,
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
                    child: SpinKitFoldingCube(
                      size: 24,
                      color: context.colorScheme.primary,
                      duration: const Duration(seconds: 1),
                    ),
                  ),
                ),
                if (error.value != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    color: context.colorScheme.error,
                    padding: const EdgeInsets.all(16),
                    child: ExceptionInfo(
                      err: error.value,
                      style: TextStyle(color: context.colorScheme.onError),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                if (data.value.id.isNotEmpty)
                  ServerDetails(
                    data: data.value,
                    isEditing: isEditing,
                    onSubmitted: (data) {
                      final serverDataNotifier =
                          ref.read(serverStateProvider.notifier);

                      if (isEditing) {
                        serverDataNotifier.edit(server, data);
                      } else {
                        serverDataNotifier.add(data);
                      }
                      context.router.pop();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
