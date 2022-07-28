import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../utils/extensions/buildcontext.dart';

class ExpandableGroupListView<T, E> extends StatelessWidget {
  const ExpandableGroupListView({
    Key? key,
    required this.items,
    required this.groupedBy,
    required this.groupTitle,
    required this.itemBuilder,
    this.expanded = true,
    this.ungroup = false,
  }) : super(key: key);

  final List<T> items;
  final E Function(T entry) groupedBy;
  final Widget Function(E key) groupTitle;
  final Widget Function(T entry) itemBuilder;
  final bool ungroup;
  final bool expanded;

  List<MapEntry<E, List<T>>> get groupedItems =>
      groupBy(items, groupedBy).entries.toList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 48),
      itemCount: ungroup ? items.length : groupedItems.length,
      itemBuilder: (context, index) {
        return ungroup
            ? itemBuilder(items[index])
            : Theme(
                data: context.theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: groupTitle(groupedItems[index].key),
                  initiallyExpanded: expanded,
                  textColor: context.colorScheme.onBackground,
                  children: groupedItems[index]
                      .value
                      .map((it) => itemBuilder(it))
                      .toList(),
                ),
              );
      },
    );
  }
}
