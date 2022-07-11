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
      appBar: AppBar(title: const Text('Server')),
      body: Column(
        children: [
          ...server.all.map((it) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
              child: ListTile(
                title: Text(it.name),
                subtitle: Text(it.homepage),
                leading: Favicon(url: '${it.homepage}/favicon.ico'),
                trailing: IconButton(
                  onPressed: () {
                    server.removeServer(data: it);
                  },
                  icon: const Icon(Icons.delete),
                ),
                dense: true,
                contentPadding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                onTap: () {},
              ),
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
    );
  }
}

class AddServer extends HookConsumerWidget {
  const AddServer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(booruApiProvider);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final data = useState<ServerData?>(null);
    final isLoading = useState(false);
    final scanText = useTextEditingController(text: 'https://');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new server'),
      ),
      body: Column(
        children: [
          Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: TextFormField(
                controller: scanText,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Example: https://abc.com',
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (isLoading.value) return;

              data.value = null;
              isLoading.value = true;
              api.scanServerUrl(scanText.text).then((res) {
                data.value = res;
              }).whenComplete(() {
                isLoading.value = false;
              });
            },
            child: const Text('Scan'),
          ),
          Visibility(
            visible: isLoading.value,
            child: Container(
              height: 64,
              alignment: Alignment.center,
              child: SpinKitThreeBounce(
                  size: 32, color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          if (data.value != null) ServerScanViewWidget(data: data.value!),
        ],
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
    final cSuggestUrl =
        useTextEditingController(text: data.tagSuggestionUrl ?? '');
    final cPostUrl = useTextEditingController(text: data.postUrl);

    return Column(
      children: [
        Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Column(
              children: [
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
                TextFormField(
                  controller: cSearchUrl,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Search Payload',
                  ),
                ),
                TextFormField(
                  controller: cSuggestUrl,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Tag Suggestion Payload',
                  ),
                ),
                TextFormField(
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
        ElevatedButton(
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
      ],
    );
  }
}
