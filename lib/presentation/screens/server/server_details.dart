import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:boorusphere/presentation/routes/app_router.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
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
    final serverData = ref.watch(serverDataStateProvider);
    final imeIncognito =
        ref.watch(uiSettingStateProvider.select((it) => it.imeIncognito));
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final cName = useTextEditingController(text: data.id);
    final cAlias = useTextEditingController(
        text: data.alias.isEmpty ? data.id : data.alias);
    final cHomepage = useTextEditingController(text: data.homepage);
    final cApiAddr = useTextEditingController(text: data.apiAddr);
    final cSearchUrl = useTextEditingController(text: data.searchUrl);
    final cSuggestUrl = useTextEditingController(text: data.tagSuggestionUrl);
    final cPostUrl = useTextEditingController(text: data.postUrl);

    openPresetPage() {
      context.router.push(
        ServerPresetRoute(
          onReturned: (newData) {
            cSearchUrl.text = newData.searchUrl;
            cSuggestUrl.text = newData.tagSuggestionUrl;
            cPostUrl.text = newData.postUrl;
          },
        ),
      );
    }

    onSave() {
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
    }

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
                    context.t.details,
                    style: context.theme.textTheme.titleMedium,
                  ),
                ),
                if (!isEditing)
                  TextFormField(
                    controller: cName,
                    enableIMEPersonalizedLearning: !imeIncognito,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Name',
                    ),
                    validator: (value) {
                      final serverName = serverData.map((it) => it.id);
                      if (!isEditing && serverName.contains(value)) {
                        return context.t.servers
                            .alreadyExists(name: value ?? '');
                      }

                      return null;
                    },
                  )
                else
                  TextFormField(
                    controller: cAlias,
                    enableIMEPersonalizedLearning: !imeIncognito,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: context.t.servers.alias,
                    ),
                  ),
                TextFormField(
                  controller: cHomepage,
                  enableIMEPersonalizedLearning: !imeIncognito,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: context.t.servers.homepage,
                  ),
                ),
                TextFormField(
                  controller: cApiAddr,
                  enableIMEPersonalizedLearning: !imeIncognito,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: context.t.servers.apiAddr,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.t.serverQuery.title,
                        style: context.theme.textTheme.titleMedium,
                      ),
                      ElevatedButton(
                        onPressed: openPresetPage,
                        child: Text(context.t.servers.preset),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  minLines: 1,
                  maxLines: 3,
                  controller: cSearchUrl,
                  enableIMEPersonalizedLearning: !imeIncognito,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: context.t.serverQuery.search,
                  ),
                  validator: (value) {
                    if (value != null &&
                        value.contains('{tags}') &&
                        value.contains('{page-id}') &&
                        value.contains('{post-limit}')) {
                      return null;
                    }

                    return context.t.servers.invalidSearchQuery;
                  },
                ),
                TextFormField(
                  minLines: 1,
                  maxLines: 3,
                  controller: cSuggestUrl,
                  enableIMEPersonalizedLearning: !imeIncognito,
                  decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: context.t.serverQuery.suggestion),
                ),
                TextFormField(
                  minLines: 1,
                  maxLines: 3,
                  controller: cPostUrl,
                  enableIMEPersonalizedLearning: !imeIncognito,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: context.t.serverQuery.post,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: ElevatedButton(
            onPressed: onSave,
            child: Text(context.t.save),
          ),
        ),
      ],
    );
  }
}
