abstract class ClipboardRepository {
  Future<void> init(String userId);
  Future<void> saveClipboard(String text);
  Stream<List<String>> getClipboard();
}
