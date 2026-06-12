import 'package:flutter/material.dart';
import 'package:sedo/themes/dark_mode.dart';
import 'package:sedo/themes/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = darkmode;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkmode;

  void toggleTheme() {
    if (_themeData == darkmode) {
      _themeData = lightmode;
    } else {
      _themeData = darkmode;
    }

    notifyListeners();
  }
}
