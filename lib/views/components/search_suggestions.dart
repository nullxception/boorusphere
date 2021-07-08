import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class SearchSuggestionResult extends StatefulWidget {
  const SearchSuggestionResult({
    Key? key,
    required this.controller,
    required this.suggestions,
    required this.history,
    this.onRemoveHistory,
  }) : super(key: key);

  final FloatingSearchBarController controller;
  final List<String> suggestions;
  final Map history;
  final Function(dynamic key)? onRemoveHistory;

  @override
  _SearchSuggestionResultState createState() => _SearchSuggestionResultState();
}

class _SearchSuggestionResultState extends State<SearchSuggestionResult> {
  String _concatSuggestionResult({
    required String input,
    required String suggested,
  }) {
    final queries = input.split(' ');
    final result = queries.sublist(0, queries.length - 1)..add(suggested);
    return '${result.join(' ')} '.replaceAll('  ', ' ').trimLeft();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Card(
          elevation: 4.0,
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                padding: const EdgeInsets.all(0),
                itemBuilder: (context, index) {
                  final rIndex = widget.history.length - 1 - index;
                  final query = widget.history.values.elementAt(rIndex).query;
                  return Column(
                    children: [
                      ListTile(
                        horizontalTitleGap: 1,
                        leading: const Icon(Icons.history, size: 24),
                        trailing: IconButton(
                          onPressed: () {
                            final key = widget.history.keys.elementAt(rIndex);
                            widget.onRemoveHistory?.call(key);
                            setState(() {});
                          },
                          icon: const Icon(Icons.close, size: 24),
                        ),
                        title: Text(query),
                        onTap: () {
                          widget.controller.query = _concatSuggestionResult(
                            input: widget.controller.query,
                            suggested: query,
                          );
                        },
                      ),
                      const Divider(height: 1),
                    ],
                  );
                },
                itemCount: widget.history.length,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                padding: const EdgeInsets.all(0),
                itemBuilder: (context, index) {
                  final query = widget.suggestions[index];
                  return Column(
                    children: [
                      ListTile(
                        horizontalTitleGap: 1,
                        leading: const Icon(Icons.tag, size: 24),
                        title: Text(query),
                        onTap: () {
                          widget.controller.query = _concatSuggestionResult(
                            input: widget.controller.query,
                            suggested: query,
                          );
                        },
                      ),
                      if (index < widget.suggestions.length - 1)
                        const Divider(height: 1),
                    ],
                  );
                },
                itemCount: widget.suggestions.length,
              ),
            ],
          )),
    );
  }
}
