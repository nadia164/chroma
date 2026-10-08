import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';

  Future<String?> loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString(_themeKey);
  }

  Future<void> saveThemeMode(String themeMode) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_themeKey, themeMode);
  }
}
