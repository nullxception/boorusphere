import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';

class NoticeCard extends StatelessWidget {
  const NoticeCard({
    super.key,
    required this.icon,
    required this.children,
    this.margin,
  });

  final Widget icon;
  final Widget children;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: margin,
      color: context.theme.cardColor,
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
