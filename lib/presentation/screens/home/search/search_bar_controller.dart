import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/presentation/provider/booru/suggestion_state.dart';
import 'package:boorusphere/presentation/routes/app_router.gr.dart';
import 'package:boorusphere/presentation/screens/home/page_args.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final searchBarControllerProvider =
    ChangeNotifierProvider.autoDispose<SearchBarController>(
        (ref) => throw UnimplementedError());

class SearchBarController extends ChangeNotifier {
  SearchBarController(this.ref, {required this.pageArgs}) {
    textEditingController.addListener(_fetch);
  }

  final Ref ref;
  final PageArgs pageArgs;

  late final textEditingController = TextEditingController(text: initial);

  bool _open = false;

  bool get isOpen => _open;
  String get value => textEditingController.value.text;
  String get initial => pageArgs.query;

  set _value(String value) {
    textEditingController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange(start: value.length, end: value.length),
    );
  }

  _fetch() {
    if (isOpen) {
      ref.read(suggestionStateProvider.notifier).get(value);
    }
  }

  void submit(BuildContext context, String newValue) {
    _value = initial;
    close();
    context.router.push(HomeRoute(
      args: pageArgs.copyWith(query: newValue),
    ));
  }

  void append(String newValue) {
    final current = value.toWordList();
    final result = {...current.take(current.length), ...newValue.toWordList()};
    _value = '${result.join(' ')} ';
  }

  void replaceLast(String newValue) {
    final current = value.toWordList();
    final result = {
      if (current.isNotEmpty) ...current.take(current.length - 1),
      ...newValue.toWordList()
    };
    _value = '${result.join(' ')} ';
  }

  void appendTyped(String newValue) {
    value.endsWith(' ') ? append(newValue) : replaceLast(newValue);
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

  @override
  void dispose() {
    textEditingController.removeListener(_fetch);
    super.dispose();
  }
}
