import 'package:flutter/material.dart';

import 'theme_service.dart';

class ThemeController extends ChangeNotifier {
  final ThemeService _themeService;

  ThemeController({ThemeService? themeService})
    : _themeService = themeService ?? ThemeService();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final savedTheme = await _themeService.loadThemeMode();

    switch (savedTheme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;

      case 'dark':
        _themeMode = ThemeMode.dark;
        break;

      default:
        _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    notifyListeners();

    await _themeService.saveThemeMode(mode.name);
  }
}
