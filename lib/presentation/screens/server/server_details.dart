import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/server_data.dart';
import 'package:boorusphere/presentation/routes/routes.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ServerDetails extends HookConsumerWidget {
  const ServerDetails({
    super.key,
    required this.data,
    required this.onSubmitted,
    required this.isEditing,
  });

  final ServerData data;
  final Function(ServerData) onSubmitted;
  final bool isEditing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverData = ref.watch(serverDataProvider);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final cName = useTextEditingController(text: data.id);
    final cAlias = useTextEditingController(
        text: data.alias.isEmpty ? data.id : data.alias);
    final cHomepage = useTextEditingController(text: data.homepage);
    final cApiAddr = useTextEditingController(text: data.apiAddr);
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
                    t.details,
                    style: context.theme.textTheme.titleMedium,
                  ),
                ),
                if (!isEditing)
                  TextFormField(
                    controller: cName,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Name',
                    ),
                    validator: (value) {
                      final serverName = serverData.map((it) => it.id);
                      if (!isEditing && serverName.contains(value)) {
                        return t.servers.alreadyExists(name: value ?? '');
                      }

                      return null;
                    },
                  )
                else
                  TextFormField(
                    controller: cAlias,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: t.servers.alias,
                    ),
                  ),
                TextFormField(
                  controller: cHomepage,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: t.servers.homepage,
                  ),
                ),
                TextFormField(
                  controller: cApiAddr,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: t.servers.apiAddr,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t.servers.payloads.title,
                        style: context.theme.textTheme.titleMedium,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.router.push(
                            ServerPayloadsRoute(
                              onReturned: (newData) {
                                cSearchUrl.text = newData.searchUrl;
                                cSuggestUrl.text = newData.tagSuggestionUrl;
                                cPostUrl.text = newData.postUrl;
                              },
                            ),
                          );
                        },
                        child: Text(t.servers.preset),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  minLines: 1,
                  maxLines: 3,
                  controller: cSearchUrl,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: t.servers.payloads.search,
                  ),
                ),
                TextFormField(
                  minLines: 1,
                  maxLines: 3,
                  controller: cSuggestUrl,
                  decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: t.servers.payloads.suggestion),
                ),
                TextFormField(
                  minLines: 1,
                  maxLines: 3,
                  controller: cPostUrl,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: t.servers.payloads.post,
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
              if (formKey.currentState?.validate() != true) {
                return;
              }

              final newData = isEditing
                  ? data.copyWith(
                      alias: cAlias.text,
                      homepage: cHomepage.text,
                      apiAddr: cApiAddr.text,
                      searchUrl: cSearchUrl.text,
                      tagSuggestionUrl: cSuggestUrl.text,
                      postUrl: cPostUrl.text,
                    )
                  : data.copyWith(
                      id: cName.text,
                      homepage: cHomepage.text,
                      apiAddr: cApiAddr.text,
                      searchUrl: cSearchUrl.text,
                      tagSuggestionUrl: cSuggestUrl.text,
                      postUrl: cPostUrl.text,
                    );
              onSubmitted.call(newData);
            },
            child: Text(t.save),
          ),
        ),
      ],
    );
  }
}
