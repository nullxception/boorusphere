import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/server_data.dart';
import '../../provider/booru_api.dart';
import '../../provider/server_data.dart';
import '../components/favicon.dart';

class ServerPage extends HookConsumerWidget {
  const ServerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref.watch(serverDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Server'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 'reset':
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Theme.of(context).colorScheme.background,
                      title: const Text('Server'),
                      content: const Text(
                        '''
Are you sure you want to reset server list to default ? \n\nThis will erase all of your added server.''',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            server.resetToDefault();
                          },
                          child: const Text('Reset'),
                        )
                      ],
                    ),
                  );
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'reset',
                  child: Text('Reset to default'),
                )
              ];
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...server.all.map((it) {
              return ListTile(
                title: Text(it.name),
                subtitle: Text(it.homepage),
                leading: Favicon(url: '${it.homepage}/favicon.ico'),
                trailing: it.name == ServerData.defaultServerName
                    ? null
                    : IconButton(
                        onPressed: () {
                          server.removeServer(data: it);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                dense: true,
                contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                onTap: null,
              );
            }).toList(),
            ListTile(
              title: const Text('Add'),
              leading: const Icon(Icons.add),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddServer()),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AddServer extends HookConsumerWidget {
  const AddServer({Key? key}) : super(key: key);

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
              if (data.value.name.isNotEmpty)
                ServerScanViewWidget(data: data.value),
            ],
          ),
        ),
      ),
    );
  }
}

class ServerScanViewWidget extends HookConsumerWidget {
  const ServerScanViewWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  final ServerData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverData = ref.watch(serverDataProvider);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final cName = useTextEditingController(text: data.name);
    final cHomepage = useTextEditingController(text: data.homepage);
    final cSearchUrl = useTextEditingController(text: data.searchUrl);
    final cSuggestUrl = useTextEditingController(text: data.tagSuggestionUrl);
    final cPostUrl = useTextEditingController(text: data.postUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    'Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextFormField(
                  controller: cName,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Name',
                  ),
                ),
                TextFormField(
                  controller: cHomepage,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Homepage',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payload',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => PayloadLoaderWidget(
                                serverData: serverData,
                                searchController: cSearchUrl,
                                suggestController: cSuggestUrl,
                                postController: cPostUrl),
                          );
                        },
                        child: const Text('From Preset'),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  minLines: 1,
                  maxLines: 3,
                  controller: cSearchUrl,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Search Payload',
                  ),
                ),
                TextFormField(
                  minLines: 1,
                  maxLines: 3,
                  controller: cSuggestUrl,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Tag Suggestion Payload',
                  ),
                ),
                TextFormField(
                  minLines: 1,
                  maxLines: 3,
                  controller: cPostUrl,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Web Post Payload',
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: ElevatedButton(
            onPressed: () {
              serverData.addServer(
                data: data.copyWith(
                  name: cName.text,
                  homepage: cHomepage.text,
                  searchUrl: cSearchUrl.text,
                  tagSuggestionUrl: cSuggestUrl.text,
                  postUrl: cPostUrl.text,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}

class PayloadLoaderWidget extends StatelessWidget {
  const PayloadLoaderWidget({
    Key? key,
    required this.serverData,
    required this.searchController,
    required this.suggestController,
    required this.postController,
  }) : super(key: key);

  final ServerDataNotifier serverData;
  final TextEditingController searchController;
  final TextEditingController suggestController;
  final TextEditingController postController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Server'),
      contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
      content: SingleChildScrollView(
        child: Column(
          children: serverData.all.map((it) {
            return ListTile(
              title: Text(it.name),
              leading: Favicon(url: '${it.homepage}/favicon.ico'),
              dense: true,
              onTap: () {
                searchController.text = it.searchUrl;
                suggestController.text = it.tagSuggestionUrl;
                postController.text = it.postUrl;
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
