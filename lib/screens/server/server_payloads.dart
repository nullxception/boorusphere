import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../widgets/favicon.dart';
import '../../source/server.dart';

class ServerPayloadsPage extends HookConsumerWidget {
  const ServerPayloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Server')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children:
                ref.read(serverDataProvider.notifier).allWithDefaults.map((it) {
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
      ),
    );
  }
}
