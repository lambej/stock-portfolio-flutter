import 'package:cloud_clipboard/app/app.dart';
import 'package:cloud_clipboard/authentication/authentication.dart';
import 'package:cloud_clipboard/bootstrap.dart';
import 'package:cloud_clipboard/firebase_options.dart';
import 'package:cloud_clipboard/text_clipboard/repository/firebase_clipboard_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final authenticationRepository = AuthenticationRepository();
  await authenticationRepository.user.first;
  final clipboardRepository = FirebaseClipboardRepository(
    firestore: FirebaseFirestore.instance,
  );
  await bootstrap(
    () => App(
      clipboardRepository: clipboardRepository,
      authenticationRepository: authenticationRepository,
    ),
  );
}
