import 'package:flutter/material.dart';
import 'package:stock_portfolio/app/app.dart';
import 'package:stock_portfolio/home/home.dart';
import 'package:stock_portfolio/login/login.dart';

List<Page<dynamic>> onGenerateAppViewPages(
  AppStatus state,
  List<Page<dynamic>> pages,
) {
  switch (state) {
    case AppStatus.appLoaded:
      return [HomePage.page()];
    case AppStatus.authenticated:
      return [MaterialPage<void>(child: Container())];
    case AppStatus.unauthenticated:
      return [LoginPage.page()];
  }
}
