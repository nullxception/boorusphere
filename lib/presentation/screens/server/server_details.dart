import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/data/repository/booru/provider.dart';
import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:boorusphere/presentation/routes/app_router.gr.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/utils/extensions/string.dart';
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
    final cSearchParser = useState(server.searchParserId);
    final cSuggestionParser = useState(server.suggestionParserId);

    useEffect(() {
      cName.text = server.id;
      cAlias.text = server.alias.isEmpty ? server.id : server.alias;
      cSearchUrl.text = server.searchUrl;
      cSuggestUrl.text = server.tagSuggestionUrl;
      cPostUrl.text = server.postUrl;
      cSearchParser.value = server.searchParserId;
      cSuggestionParser.value = server.suggestionParserId;
    }, [server]);

    openPresetPage() {
      context.router.push(
        ServerPresetRoute(
          onReturned: (newData) {
            cSearchUrl.text = newData.searchUrl;
            cSuggestUrl.text = newData.tagSuggestionUrl;
            cPostUrl.text = newData.postUrl;
            cSearchParser.value = newData.searchParserId;
            cSuggestionParser.value = newData.suggestionParserId;
          },
        ),
      );
    }

    onSave() {
      if (formKey.currentState?.validate() != true) {
        return;
      }

      var newData = isEditing
          ? server.copyWith(alias: cAlias.text)
          : server.copyWith(id: cName.text);
      newData = newData.copyWith(
        searchUrl: cSearchUrl.text,
        tagSuggestionUrl: cSuggestUrl.text,
        postUrl: cPostUrl.text,
        searchParserId: cSearchParser.value,
        suggestionParserId: cSuggestionParser.value,
      );

      onSubmitted.call(newData);
    }

    final parsers = ref.read(booruParsersProvider);

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
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: context.t.servers.id,
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
                ParserSelector(
                  label: context.t.servers.parserType.search,
                  type: BooruParserType.search,
                  parsers: parsers,
                  value: cSearchParser.value,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      cSearchParser.value = newValue;
                    }
                  },
                ),
                ParserSelector(
                  label: context.t.servers.parserType.suggestion,
                  type: BooruParserType.suggestion,
                  parsers: parsers,
                  value: cSuggestionParser.value,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      cSuggestionParser.value = newValue;
                    }
                  },
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

class ParserSelector extends HookWidget {
  const ParserSelector({
    super.key,
    required List<BooruParser> parsers,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.type,
  }) : _parsers = parsers;

  final void Function(String? newValue) onChanged;
  final List<BooruParser> _parsers;
  final BooruParserType type;
  final String value;
  final String label;

  List<BooruParser> get parsers {
    return _parsers.where((x) => x.type.contains(type)).toList();
  }

  Future<String?> selectParser(
    BuildContext context,
    String title,
    List<BooruParser> parsers,
    String current,
  ) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          icon: const Icon(Icons.star),
          contentPadding: const EdgeInsets.only(top: 16, bottom: 16),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: parsers.length,
              shrinkWrap: true,
              itemBuilder: (context, index) => RadioListTile(
                value: parsers[index].id,
                groupValue: current,
                title: ParserLabel(id: parsers[index].id),
                onChanged: (x) {
                  context.navigator.pop(x);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Text(
            label,
            style: context.theme.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ),
        InkWell(
          child: Container(
            color: context.colorScheme.surface,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ParserLabel(id: value),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          onTap: () async {
            FocusScope.of(context).unfocus();

            onChanged.call(await selectParser(context, label, parsers, value));
          },
        )
      ],
    );
  }
}

class ParserLabel extends StatelessWidget {
  const ParserLabel({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    if (id.isEmpty) {
      return Text(context.t.auto);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(id.fileNameNoExt),
        const SizedBox(width: 4),
        Card(
          color: switch (id.fileExt.toLowerCase()) {
            'json' => context.colorScheme.primary,
            _ => context.colorScheme.tertiary,
          },
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              id.fileExt.toUpperCase(),
              style: TextStyle(
                color: context.colorScheme.onPrimary,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
