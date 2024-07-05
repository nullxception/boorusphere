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

  Map<E, Iterable<T>> get grouped {
    return groupBy(items, groupedBy);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 48),
      itemCount: ungroup ? items.length : grouped.length,
      itemBuilder: (context, index) {
        if (!ungroup) {
          final group = grouped.entries.atReverse(index);
          return Theme(
            data: context.theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: groupTitle(group.key),
              initiallyExpanded: expanded,
              textColor: context.colorScheme.onSurface,
              children: group.value.map(itemBuilder).toList(),
            ),
          );
        }

        return itemBuilder(items.atReverse(index));
      },
    );
  }
}

extension _IterableExt<T> on Iterable<T> {
  T atReverse(int index) {
    return elementAt(length - index - 1);
  }
}
