import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class ExpandableGroupListView<T, E> extends StatelessWidget {
  const ExpandableGroupListView({
    super.key,
    required this.items,
    required this.groupedBy,
    required this.groupTitle,
    required this.itemBuilder,
    this.expanded = true,
    this.ungroup = false,
  });

  final Iterable<T> items;
  final E Function(T entry) groupedBy;
  final Widget Function(E key) groupTitle;
  final Widget Function(T entry) itemBuilder;
  final bool ungroup;
  final bool expanded;

  Iterable<MapEntry<E, Iterable<T>>> get grouped =>
      groupBy(items, groupedBy).entries;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 48),
      itemCount: ungroup ? items.length : grouped.length,
      itemBuilder: (context, i) {
        return ungroup
            ? itemBuilder(items.elementAt(i))
            : Theme(
                data: context.theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: groupTitle(grouped.elementAt(i).key),
                  initiallyExpanded: expanded,
                  textColor: context.colorScheme.onBackground,
                  children:
                      grouped.elementAt(i).value.map(itemBuilder).toList(),
                ),
              );
      },
    );
  }
}
