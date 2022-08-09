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

  String get hint {
    final serverActive = ref.watch(activeServerProvider);
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

  void append(String suggested) {
    final queries = _textController.text.replaceAll('  ', ' ').split(' ');
    final result = queries.sublist(0, queries.length - 1).toSet()
      ..addAll(suggested.split(' '));
    text = '${result.join(' ')} ';
  }

  void reset() {
    text = initialText;
  }

  void clear() {
    _textController.clear();
    notifyListeners();
  }

  void rebuildHistory() {
    ref.read(searchHistoryProvider.notifier).rebuild(text);
  }

  void open() {
    rebuildHistory();
    _isOpen = true;
    notifyListeners();
    _textController.addListener(rebuildHistory);
  }

  void close() {
    _isOpen = false;
    notifyListeners();
    _textController.removeListener(rebuildHistory);
  }
}
