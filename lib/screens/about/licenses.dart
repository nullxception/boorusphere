import 'package:flutter/material.dart';

import '../../generated_licenses.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open Source Licenses')),
      body: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: ossLicenses.length,
        itemBuilder: (context, index) {
          final item = ossLicenses[index];
          return ExpansionTile(
            title: Text('${item.name} v${item.version}'),
            children: [
              if (item.license?.isNotEmpty ?? false)
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.license ?? ''),
                    ],
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}
