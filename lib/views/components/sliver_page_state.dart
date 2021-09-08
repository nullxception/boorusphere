import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../provider/booru_api.dart';

class SliverPageState extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final api = useProvider(booruApiProvider);
    final pageLoading = useProvider(pageLoadingProvider);
    final errorMessage = useProvider(pageErrorProvider);

    return SliverToBoxAdapter(
      child: Column(
        children: [
          if (errorMessage.state.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Icon(Icons.search_off),
                  ),
                  Text(errorMessage.state, textAlign: TextAlign.center),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: ElevatedButton(
                        onPressed: api.loadMore,
                        child: const Text('try again')),
                  )
                ],
              ),
            ),
          if (pageLoading.state)
            Container(
              height: 64,
              alignment: Alignment.center,
              child: SpinKitThreeBounce(
                  size: 32, color: Theme.of(context).colorScheme.secondary),
            ),
        ],
      ),
    );
  }
}
