import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/server_data.dart';
import 'package:boorusphere/presentation/widgets/favicon.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ServerPayloadsPage extends HookConsumerWidget {
  const ServerPayloadsPage({super.key, this.onReturned});

  final void Function(ServerData newData)? onReturned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.servers.select)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: ref.read(serverDataStateProvider.notifier).all.map((it) {
              return ListTile(
                title: Text(it.name),
                subtitle: Text(it.homepage),
                leading: Favicon(url: it.homepage),
                dense: true,
                onTap: () {
                  onReturned?.call(it);
                  context.router.pop();
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
