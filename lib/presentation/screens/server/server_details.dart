import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:boorusphere/presentation/routes/app_router.gr.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ServerDetails extends HookConsumerWidget {
  const ServerDetails({
    super.key,
    required this.server,
    required this.onSubmitted,
    required this.isEditing,
  });

  final Server server;
  final Function(Server) onSubmitted;
  final bool isEditing;

  bool hasProperServerQuery(String? value) {
    if (value == null) {
      return false;
    }

    return value.contains('{tags}') &&
        value.contains(RegExp(r'\{(page-id|post-offset)\}')) &&
        value.contains('{post-limit}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (server.id.isEmpty) {
      // No server.id means adding a new server
      return const SizedBox.shrink();
    }

    final servers = ref.watch(serverStateProvider);
    final imeIncognito =
        ref.watch(uiSettingStateProvider.select((it) => it.imeIncognito));
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final cName = useTextEditingController(text: server.id);
    final cAlias = useTextEditingController(
        text: server.alias.isEmpty ? server.id : server.alias);
    final cSearchUrl = useTextEditingController(text: server.searchUrl);
    final cSuggestUrl = useTextEditingController(text: server.tagSuggestionUrl);
    final cPostUrl = useTextEditingController(text: server.postUrl);

    useEffect(() {
      cName.text = server.id;
      cAlias.text = server.alias.isEmpty ? server.id : server.alias;
      cSearchUrl.text = server.searchUrl;
      cSuggestUrl.text = server.tagSuggestionUrl;
      cPostUrl.text = server.postUrl;
    }, [server]);

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
          ? server.copyWith(
              alias: cAlias.text,
              searchUrl: cSearchUrl.text,
              tagSuggestionUrl: cSuggestUrl.text,
              postUrl: cPostUrl.text,
            )
          : server.copyWith(
              id: cName.text,
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
                if (!isEditing)
                  TextFormField(
                    controller: cName,
                    enableIMEPersonalizedLearning: !imeIncognito,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Name',
                    ),
                    validator: (value) {
                      final serverName = servers.map((it) => it.id);
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
                    if (hasProperServerQuery(value)) {
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
