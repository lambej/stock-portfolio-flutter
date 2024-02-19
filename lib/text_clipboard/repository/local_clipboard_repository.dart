import 'dart:convert';
import 'package:cloud_clipboard/text_clipboard/repository/clipboard_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalClipboardRepository extends ClipboardRepository {
  LocalClipboardRepository({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  final _clipboardTextStreamController =
      BehaviorSubject<List<String>>.seeded(const []);

  static const kClipboardTextCollectionKey =
      '__clipboard_text_collection_key__';

  String? _getValue(String key) => sharedPreferences.getString(key);
  Future<void> _setValue(String key, String value) =>
      sharedPreferences.setString(key, value);

  Future<void> _initClipboardTexts() async {
    final clipboardTextsJson = _getValue(kClipboardTextCollectionKey);
    if (clipboardTextsJson != null) {
      final clipboardTexts = List<Map<dynamic, dynamic>>.from(
        json.decode(clipboardTextsJson) as List,
      ).map((e) => e as String).toList();
      _clipboardTextStreamController.add(clipboardTexts);
    } else {
      _clipboardTextStreamController.add(const []);
    }
  }

  @override
  Future<void> init(String userId) async {
    await _initClipboardTexts();
  }

  @override
  Stream<List<String>> getClipboard() =>
      _clipboardTextStreamController.asBroadcastStream();

  @override
  Future<void> saveClipboard(String text) async {
    final clipboard = [..._clipboardTextStreamController.value, text];

    _clipboardTextStreamController.add(clipboard);
    return _setValue(kClipboardTextCollectionKey, json.encode(clipboard));
  }
}
