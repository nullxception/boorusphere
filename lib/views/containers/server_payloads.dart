import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../provider/server_data.dart';
import '../components/favicon.dart';

class ServerPayloadsPage extends HookConsumerWidget {
  const ServerPayloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverDataNotifier = ref.watch(serverDataProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Server')),
      body: SingleChildScrollView(
        child: Column(
          children: serverDataNotifier.allWithDefaults.map((it) {
            return ListTile(
              title: Text(it.name),
              subtitle: Text(it.homepage),
              leading: Favicon(url: '${it.homepage}/favicon.ico'),
              dense: true,
              onTap: () {
                Navigator.pop(context, it);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
