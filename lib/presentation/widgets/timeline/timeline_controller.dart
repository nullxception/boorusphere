import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

TimelineController useTimelineController({
  List<Object?> keys = const [],
  void Function()? onLoadMore,
}) {
  return useMemoized(
    () => TimelineController(onLoadMore: onLoadMore),
    keys,
  );
}

class TimelineController extends ChangeNotifier {
  TimelineController({
    this.onLoadMore,
  }) {
    _scrollController.addListener(_autoLoadMore);
  }

  final void Function()? onLoadMore;
  final _scrollController = AutoScrollController(axis: Axis.vertical);

  AutoScrollController get scrollController => _scrollController;

  void revealAt(int dest) {
    if (!scrollController.hasClients || scrollController.isAutoScrolling) {
      return;
    }

    if (scrollController.isIndexStateInLayoutRange(dest)) {
      scrollController.scrollToIndex(dest);
    } else {
      scrollController
          .scrollToIndex(
            dest,
            duration: const Duration(milliseconds: 800),
          )
          .whenComplete(() => scrollController.highlight(dest,
              highlightDuration: const Duration(milliseconds: 150)));
    }
  }

  void loadMoreData() {
    onLoadMore?.call();
  }

  void _autoLoadMore() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.extentAfter < 200) {
      loadMoreData();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_autoLoadMore);
    super.dispose();
  }
}
