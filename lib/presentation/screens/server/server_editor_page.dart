import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:boorusphere/presentation/screens/home/search_session.dart';
import 'package:boorusphere/presentation/screens/server/server_details.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/utils/server_scanner.dart';
import 'package:boorusphere/presentation/widgets/error_info.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage()
class ServerEditorPage extends HookConsumerWidget {
  const ServerEditorPage({super.key, this.server = ServerData.empty});

  final ServerData server;

  bool get isEditing => server != ServerData.empty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dio = ref.watch(dioProvider);
    final session = ref.watch(searchSessionProvider);
    final scanner = useMemoized(() => ServerScanner(dio), [dio]);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final imeIncognito =
        ref.watch(uiSettingStateProvider.select((it) => it.imeIncognito));
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
        return context.t.servers.addrError;
      }

      return null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? context.t.servers.edit(name: server.name)
              : context.t.servers.add,
        ),
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
                      if (isLoading.value) {
                        scanner.cancel();
                        isLoading.value = false;
                        return;
                      }

                      data.value = ServerData.empty;
                      isLoading.value = true;
                      error.value = null;
                      final homeAddr = scanHomepageText.text;
                      final apiAddr =
                          useApiAddr.value ? scanApiAddrText.text : homeAddr;
                      try {
                        final res = await scanner.scan(homeAddr, apiAddr);
                        data.value = res.apiAddr == res.homepage
                            ? res.copyWith(apiAddr: '')
                            : res;
                      } catch (e) {
                        error.value = e;
                        data.value = ServerData.empty.copyWith(
                          id: homeAddr.toUri().host,
                          homepage: homeAddr,
                        );
                      }

                      isLoading.value = false;
                    },
                    child: Text(
                      isLoading.value ? context.t.cancel : context.t.scan,
                    ),
                  ),
                ),
                if (isLoading.value)
                  Container(
                    height: 64,
                    alignment: Alignment.center,
                    child: const RefreshProgressIndicator(),
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
                if (data.value.id.isNotEmpty)
                  ServerDetails(
                    data: data.value,
                    isEditing: isEditing,
                    onSubmitted: (data) {
                      final serverDataNotifier =
                          ref.read(serverDataStateProvider.notifier);

                      if (isEditing) {
                        serverDataNotifier.edit(session, server, data);
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
