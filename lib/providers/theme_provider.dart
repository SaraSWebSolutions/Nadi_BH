import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeMode> {
  static const String themeKey = 'theme';

  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  // Load saved theme
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getString(themeKey) ?? 'system';

    switch (saved) {
      case 'dark':
        state = ThemeMode.dark;
        break;

      case 'light':
        state = ThemeMode.light;
        break;

      default:
        state = ThemeMode.system;
    }
  }

  // Change + Save theme
  Future<void> changeTheme(ThemeMode mode) async {
    state = mode;

    final prefs = await SharedPreferences.getInstance();

    String value;

    switch (mode) {
      case ThemeMode.dark:
        value = 'dark';
        break;

      case ThemeMode.light:
        value = 'light';
        break;

      case ThemeMode.system:
        value = 'system';
        break;
    }

    await prefs.setString(themeKey, value);
  }
}
