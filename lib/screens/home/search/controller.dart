part of 'search.dart';

final searchBarController = ChangeNotifierProvider((ref) {
  final pageQuery = ref.watch(pageOptionProvider.select((it) => it.query));
  return SearchBarController(ref, pageQuery);
});

class SearchBarController extends ChangeNotifier {
  SearchBarController(this.ref, this.initialText);

  final Ref ref;
  final String initialText;
  late final _textController = TextEditingController(text: initialText);
  bool _isOpen = false;

  bool get isOpen => _isOpen;
  bool get isTextChanged => _textController.value.text != initialText;

  String get hint {
    final serverActive = ref.watch(serverActiveProvider);
    return _textController.text.isEmpty
        ? 'Search on ${serverActive.name}...'
        : _textController.text;
  }

  String get text => _textController.value.text;

  set text(String value) {
    _textController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange(start: value.length, end: value.length),
    );
  }

  void submit(String value) {
    text = value;
    close();
    ref
        .read(pageOptionProvider.notifier)
        .update((state) => PageOption(query: value, clear: true));
  }

  void append(String value) {
    final current = text.toWordList();
    final result = {...current.take(current.length), ...value.toWordList()};
    text = '${result.join(' ')} ';
  }

  void reset() {
    text = initialText;
    notifyListeners();
  }

  void clear() {
    _textController.clear();
    notifyListeners();
  }

  void open() {
    _isOpen = true;
    notifyListeners();
  }

  void close() {
    _isOpen = false;
    notifyListeners();
  }

  void addTextListener(Function() cb) {
    _textController.addListener(cb);
  }

  void removeTextListener(Function() cb) {
    _textController.removeListener(cb);
  }
}
