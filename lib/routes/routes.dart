import 'package:cloud_clipboard/app/app.dart';
import 'package:cloud_clipboard/login/login.dart';
import 'package:cloud_clipboard/text_clipboard/text_clipboard.dart';
import 'package:flutter/material.dart';

List<Page<dynamic>> onGenerateAppViewPages(
  AppStatus state,
  List<Page<dynamic>> pages,
) {
  switch (state) {
    case AppStatus.appLoaded:
      return [TextClipboardPage.page()];
    case AppStatus.authenticated:
      return [MaterialPage<void>(child: Container())];
    case AppStatus.unauthenticated:
      return [LoginPage.page()];
  }
}
