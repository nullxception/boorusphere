import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../provider/booru_api.dart';

class SliverPageState extends HookConsumerWidget {
  const SliverPageState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(booruApiProvider);
    final pageLoading = ref.watch(pageLoadingProvider);
    final errorMessage = ref.watch(pageErrorProvider);

    return SliverToBoxAdapter(
      child: Column(
        children: [
          if (errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Icon(Icons.search_off),
                  ),
                  Text(errorMessage, textAlign: TextAlign.center),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: ElevatedButton(
                        onPressed: api.loadMore,
                        child: const Text('Try again')),
                  )
                ],
              ),
            ),
          if (pageLoading)
            Container(
              height: 90,
              alignment: Alignment.center,
              child: SpinKitThreeBounce(
                  size: 32, color: Theme.of(context).colorScheme.primary),
            ),
          if (errorMessage.isEmpty && !pageLoading && api.posts.isNotEmpty)
            Container(
              height: 90,
              alignment: Alignment.center,
              child: ElevatedButton(
                  onPressed: api.loadMore, child: const Text('Load more')),
            )
        ],
      ),
    );
  }
}
