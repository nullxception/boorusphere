import 'package:flutter/material.dart';

import '../../util/license.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final licenses = LicenseUtil.getLicenses();
    licenses.sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      appBar: AppBar(title: const Text('Open Source Licenses')),
      body: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: licenses.length,
        itemBuilder: (context, index) {
          final item = licenses[index];
          return ExpansionTile(
            title: Text(item.name),
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.license),
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
