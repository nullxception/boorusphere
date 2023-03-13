import 'package:boorusphere/presentation/screens/home/page_args.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

final timelineControllerProvider =
    ChangeNotifierProvider.autoDispose<TimelineController>(
        (ref) => throw UnimplementedError());

class TimelineController extends ChangeNotifier {
  TimelineController({
    this.onLoadMore,
    required this.pageArgs,
  }) {
    _scrollController.addListener(_autoLoadMore);
  }

  final Future<void> Function()? onLoadMore;

  final PageArgs pageArgs;
  final _scrollController = AutoScrollController(axis: Axis.vertical);

  AutoScrollController get scrollController => _scrollController;

  Future<void> _autoLoadMore() async {
    if (!scrollController.hasClients) return;
    if (scrollController.position.extentAfter < 200) {
      await onLoadMore?.call();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_autoLoadMore);
    super.dispose();
  }

  void scrollTo(int index) {
    if (!scrollController.hasClients) return;

    scrollController.scrollToIndex(index);
  }
}
