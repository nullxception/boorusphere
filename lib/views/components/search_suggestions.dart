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
  void _addToInput(String suggested) {
    final queries = widget.controller.query.split(' ');
    final result = queries.sublist(0, queries.length - 1)..add(suggested);
    widget.controller.query =
        '${result.join(' ')} '.replaceAll('  ', ' ').trimLeft();
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
                      _SuggestionEntry(
                        query: query,
                        onTap: () {
                          widget.controller.query = query;
                        },
                        onAdded: () {
                          _addToInput(query);
                        },
                        onRemoved: () {
                          final key = widget.history.keys.elementAt(rIndex);
                          widget.onRemoveHistory?.call(key);
                          setState(() {});
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
                      _SuggestionEntry(
                        query: query,
                        onTap: () {
                          widget.controller.query = query;
                        },
                        onAdded: () {
                          _addToInput(query);
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

class _SuggestionEntry extends StatelessWidget {
  const _SuggestionEntry({
    Key? key,
    required this.query,
    required this.onTap,
    required this.onAdded,
    this.onRemoved,
  }) : super(key: key);

  final String query;
  final Function() onTap;
  final Function() onAdded;
  final Function()? onRemoved;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 12),
      horizontalTitleGap: 1,
      leading: const Icon(Icons.history, size: 22),
      title: Text(query),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onAdded,
            icon: const Icon(Icons.add, size: 22),
          ),
          onRemoved != null
              ? IconButton(
                  onPressed: onRemoved,
                  icon: const Icon(Icons.close, size: 22),
                )
              : const SizedBox(width: 8 * 3 + 24),
        ],
      ),
    );
  }
}
