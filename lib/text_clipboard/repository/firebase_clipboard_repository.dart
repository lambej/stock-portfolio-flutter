import 'package:cloud_clipboard/text_clipboard/repository/clipboard_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseClipboardRepository implements ClipboardRepository {
  FirebaseClipboardRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;
  late String _userId;
  final _clipboardTextStreamController =
      BehaviorSubject<List<String>>.seeded(const []);

  static const kClipboardTextCollectionKey = 'Clipboard_Texts';

  Future<void> _initClipboardTexts() async {
    final clipboardTextsJson = await _firestore
        .collection(kClipboardTextCollectionKey)
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .get();

    final clipboardTexts =
        clipboardTextsJson.docs.map((e) => e.data()['text'] as String).toList();
    _clipboardTextStreamController.add(clipboardTexts);
  }

  @override
  Future<void> init(String userId) async {
    _userId = userId;
    await _initClipboardTexts();
  }

  @override
  Future<void> saveClipboard(
    String text,
  ) async {
    final clipboard = [text, ..._clipboardTextStreamController.value];
    _clipboardTextStreamController.add(clipboard);
    await _firestore.collection(kClipboardTextCollectionKey).add({
      'text': text,
      'userId': _userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<String>> getClipboard() async* {
    yield* _clipboardTextStreamController.asBroadcastStream();
  }
}
