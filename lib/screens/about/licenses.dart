import 'package:flutter/material.dart';

import '../../generated_licenses.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final licenses = ossLicenses.where((it) => it.isDirectDependency).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Open Source Licenses')),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: licenses.length,
          itemBuilder: (context, index) {
            final item = licenses[index];
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
      ),
    );
  }
}
