import 'package:cloud_clipboard/app/app.dart';
import 'package:cloud_clipboard/authentication/authentication.dart';
import 'package:cloud_clipboard/bootstrap.dart';
import 'package:cloud_clipboard/text_clipboard/repository/local_clipboard_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final authenticationRepository = AuthenticationRepository();
  await authenticationRepository.user.first;
  final clipboardRepository = LocalClipboardRepository(
    sharedPreferences: await SharedPreferences.getInstance(),
  );
  await bootstrap(
    () => App(
      clipboardRepository: clipboardRepository,
      authenticationRepository: authenticationRepository,
    ),
  );
}
