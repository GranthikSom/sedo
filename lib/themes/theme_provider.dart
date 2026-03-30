import 'package:flutter/material.dart';
import 'package:sedo/themes/dark_mode.dart' show darkmode;
import 'package:sedo/themes/light_mode.dart' show lightmode;

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightmode;

  ThemeData? themeData;

  get themeDate => _themeData;

  bool get isDarkMode => _themeData == darkmode;

  set themedata(ThemeData themedata) {
    _themeData = themedata;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightmode) {
      _themeData = darkmode;
    } else {
      _themeData = lightmode;
    }
    notifyListeners();
  }
}
