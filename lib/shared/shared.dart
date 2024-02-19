import 'package:url_launcher/url_launcher.dart';

Future<void> launchURL(String urlToLaunch) async {
  final url = Uri.parse(urlToLaunch);
  if (await launchUrl(url)) {
    await launchUrl(url);
  } else {
    // ignore: only_throw_errors
    throw 'Could not launch $url';
  }
}
