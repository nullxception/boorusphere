import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../../model/search_history.dart';

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
  final Iterable<SearchHistory> history;
  final Function(int index)? onRemoveHistory;

  @override
  _SearchSuggestionResultState createState() => _SearchSuggestionResultState();
}

class _SearchSuggestionResultState extends State<SearchSuggestionResult> {
  get dataCount => widget.suggestions.isEmpty
      ? widget.history.length
      : widget.suggestions.length;

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
          child: ListView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            padding: const EdgeInsets.all(0),
            itemBuilder: (context, index) {
              final query = widget.suggestions.isEmpty
                  ? widget.history.elementAt(index).query
                  : widget.suggestions[index];

              return Column(
                children: [
                  ListTile(
                    horizontalTitleGap: 1,
                    leading: Icon(
                      widget.suggestions.isEmpty ? Icons.history : Icons.tag,
                      size: 24,
                    ),
                    trailing: widget.suggestions.isEmpty
                        ? IconButton(
                            onPressed: () {
                              widget.onRemoveHistory?.call(index);
                              setState(() {});
                            },
                            icon: const Icon(Icons.close, size: 24),
                          )
                        : null,
                    title: Text(query),
                    onTap: () {
                      widget.controller.query = _concatSuggestionResult(
                        input: widget.controller.query,
                        suggested: query,
                      );
                    },
                  ),
                  if (index < dataCount - 1) const Divider(height: 1),
                ],
              );
            },
            itemCount: dataCount,
          )),
    );
  }
}
