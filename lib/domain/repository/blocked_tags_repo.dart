abstract class BlockedTagsRepo {
  Map<int, String> get();
  Future<void> delete(key);
  Future<void> push(String value);
}
