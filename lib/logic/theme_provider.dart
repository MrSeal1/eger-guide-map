import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  // alap, Colors.green[700] megfelelője
  Color _accentColor = const Color.fromARGB(255, 56, 142, 60);

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  Color get accentColor => _accentColor;

  ThemeProvider() {
    _loadLocalSettings();
  }

  Future<void> _loadLocalSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final isLocalDark = prefs.getBool('isDarkMode');
    if(isLocalDark != null) {
      _themeMode = isLocalDark ? ThemeMode.dark : ThemeMode.light;
    }

    final localColor = prefs.getInt('accentColor');
    if(localColor != null) {
      _accentColor = Color(localColor);
    }

    notifyListeners();
  }

  Future<void> toggleTheme(bool isOn) async {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isOn);
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColor', color.toARGB32());
  }
}