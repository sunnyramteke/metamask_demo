import 'package:flutter/material.dart';

import '../utilities/prefrences.dart';

class DarkThemeProvider with ChangeNotifier {
  DarkThemePreference darkThemePreference = DarkThemePreference();
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  void changeTheme() {
    _darkTheme = !darkTheme;
    darkThemePreference.setDarkTheme(_darkTheme);
    notifyListeners();
  }

  loadThemePreference() async {
    _darkTheme = await darkThemePreference.getTheme();
    notifyListeners();
  }
}
