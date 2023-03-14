import 'package:boorusphere/presentation/screens/home/page_args.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

final timelineControllerProvider =
    ChangeNotifierProvider.autoDispose<TimelineController>(
        (ref) => throw UnimplementedError());

class TimelineController extends ChangeNotifier {
  TimelineController({
    required this.scrollController,
    required this.pageArgs,
    this.onLoadMore,
  }) {
    scrollController.addListener(_autoLoadMore);
  }

  final AutoScrollController scrollController;
  final PageArgs pageArgs;
  final Future<void> Function()? onLoadMore;

  Future<void> _autoLoadMore() async {
    if (!scrollController.hasClients) return;
    if (scrollController.position.extentAfter < 200) {
      await onLoadMore?.call();
    }
  }

  void scrollTo(int index) {
    if (!scrollController.hasClients) return;

    scrollController.scrollToIndex(index);
  }

  @override
  void dispose() {
    scrollController.removeListener(_autoLoadMore);
    super.dispose();
  }
}
