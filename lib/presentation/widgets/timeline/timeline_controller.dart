import 'package:boorusphere/presentation/screens/home/page_args.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

TimelineController useTimelineController({
  List<Object?> keys = const [],
  required PageArgs pageArgs,
  Future<void> Function()? onLoadMore,
}) {
  return useMemoized(
    () => TimelineController(
      pageArgs: pageArgs,
      onLoadMore: onLoadMore,
    ),
    keys,
  );
}

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
}
