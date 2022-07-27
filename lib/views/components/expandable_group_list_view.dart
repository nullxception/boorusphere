import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class ExpandableGroupListView<T, E> extends StatelessWidget {
  const ExpandableGroupListView({
    Key? key,
    required this.entries,
    required this.groupedBy,
    required this.groupTitle,
    required this.itemBuilder,
    this.expanded = true,
    this.ungroup = false,
  }) : super(key: key);

  final List<T> entries;
  final E Function(T entry) groupedBy;
  final Widget Function(E key) groupTitle;
  final Widget Function(T entry) itemBuilder;
  final bool ungroup;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 48),
      children: !ungroup
          ? groupBy(entries, groupedBy).entries.map(
              (groupedEntries) {
                return ExpansionTile(
                  title: groupTitle(groupedEntries.key),
                  initiallyExpanded: expanded,
                  children: groupedEntries.value
                      .map((it) => itemBuilder(it))
                      .toList(),
                );
              },
            ).toList()
          : entries.map((it) => itemBuilder(it)).toList(),
    );
  }
}
