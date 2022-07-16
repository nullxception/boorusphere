import 'package:flutter/material.dart';

class NoticeCard extends StatelessWidget {
  const NoticeCard({
    Key? key,
    required this.icon,
    required this.children,
    this.margin,
  }) : super(key: key);

  final Widget icon;
  final Widget children;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: margin,
      color: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            icon,
            const SizedBox(height: 16),
            children,
          ],
        ),
      ),
    );
  }
}
