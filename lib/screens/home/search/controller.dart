part of 'search.dart';

final searchBarController = ChangeNotifierProvider((ref) {
  final pageQuery = ref.watch(pageOptionProvider.select((it) => it.query));
  return SearchBarController(ref, pageQuery);
});

class SearchBarController extends ChangeNotifier {
  SearchBarController(this.ref, this.initialValue);
  final Ref ref;

  bool isOpen = false;

  final String initialValue;

  late final _textController = TextEditingController(text: initialValue);

  String get text => _textController.text;
  String get hint {
    final serverActive = ref.watch(activeServerProvider);
    return _textController.text.isEmpty
        ? 'Search on ${serverActive.name}...'
        : _textController.text;
  }

  set query(String value) {
    _textController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange(start: value.length, end: value.length),
    );
  }

  void submit(String value) {
    query = value;
    close();
    ref
        .read(pageOptionProvider.notifier)
        .update((state) => PageOption(query: value, clear: true));
  }

  void append(String suggested) {
    final queries = _textController.text.replaceAll('  ', ' ').split(' ');
    final result = queries.sublist(0, queries.length - 1).toSet()
      ..addAll(suggested.split(' '));
    query = '${result.join(' ')} ';
  }

  void reset() {
    query = initialValue;
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
    isOpen = true;
    notifyListeners();
    _textController.addListener(rebuildHistory);
  }

  void close() {
    isOpen = false;
    notifyListeners();
    _textController.removeListener(rebuildHistory);
  }
}
