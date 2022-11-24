import 'package:boorusphere/presentation/provider/booru/page_state.dart';
import 'package:boorusphere/presentation/provider/booru/suggestion_state.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final searchBarController = ChangeNotifierProvider.autoDispose((ref) {
  final query = ref.watch(pageStateProvider.select(
    (it) => it.data.option.query,
  ));
  return SearchBarController(ref, query);
});

class SearchBarController extends ChangeNotifier {
  SearchBarController(this.ref, this.initial) {
    textEditingController.addListener(_fetch);

    ref.onDispose(() {
      textEditingController.removeListener(_fetch);
    });
  }

  final Ref ref;
  final String initial;

  late final textEditingController = TextEditingController(text: initial);

  bool _open = false;

  bool get isOpen => _open;
  String get value => textEditingController.value.text;

  set _value(String value) {
    textEditingController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange(start: value.length, end: value.length),
    );
  }

  _fetch() {
    ref.read(suggestionStateProvider.notifier).get(value);
  }

  void submit(String value) {
    _value = value;
    close();
    ref
        .read(pageStateProvider.notifier)
        .update((state) => state.copyWith(query: value, clear: true));
  }

  void append(String value) {
    final current = value.toWordList();
    final result = {...current.take(current.length), ...value.toWordList()};
    _value = '${result.join(' ')} ';
  }

  void reset() {
    _value = initial;
    notifyListeners();
  }

  void open() {
    _open = true;
    notifyListeners();
  }

  void close() {
    _open = false;
    notifyListeners();
  }

  void clear() {
    if (value.isEmpty) {
      reset();
      close();
    } else {
      textEditingController.clear();
      notifyListeners();
    }
  }
}
