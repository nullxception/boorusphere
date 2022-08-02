import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../entity/server_data.dart';
import '../../source/server.dart';
import '../../utils/extensions/buildcontext.dart';
import 'server_payloads.dart';

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
                    style: context.theme.textTheme.titleMedium,
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
                  validator: (value) {
                    final homescreens = serverData.map((it) => it.homepage);
                    if (!isEditing && homescreens.contains(value)) {
                      return 'Server data for $value already exists';
                    }

                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payload',
                        style: context.theme.textTheme.titleMedium,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final result =
                              await context.navigator.push<ServerData>(
                            MaterialPageRoute(
                              builder: (context) => const ServerPayloadsPage(),
                            ),
                          );

                          if (result != null) {
                            cSearchUrl.text = result.searchUrl;
                            cSuggestUrl.text = result.tagSuggestionUrl;
                            cPostUrl.text = result.postUrl;
                          }
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
              if (formKey.currentState?.validate() != true) {
                return;
              }

              onSubmitted.call(data.copyWith(
                name: cName.text,
                homepage: cHomepage.text,
                searchUrl: cSearchUrl.text,
                tagSuggestionUrl: cSuggestUrl.text,
                postUrl: cPostUrl.text,
              ));
            },
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}
