import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _prefKeyTheme = 'lumaspace_theme_preset';

  AppThemePreset _currentPreset = AppThemePreset.system;
  final SharedPreferences? _prefs;

  ThemeProvider([this._prefs]) {
    _loadTheme();
  }

  AppThemePreset get currentPreset => _currentPreset;

  void _loadTheme() {
    if (_prefs != null) {
      final savedName = _prefs.getString(_prefKeyTheme);
      if (savedName != null) {
        _currentPreset = AppThemePreset.fromString(savedName);
        notifyListeners();
      }
    } else {
      SharedPreferences.getInstance().then((prefs) {
        final savedName = prefs.getString(_prefKeyTheme);
        if (savedName != null) {
          _currentPreset = AppThemePreset.fromString(savedName);
          notifyListeners();
        }
      });
    }
  }

  Future<void> setThemePreset(AppThemePreset preset) async {
    if (_currentPreset == preset) return;
    _currentPreset = preset;
    notifyListeners();

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyTheme, preset.name);
  }

  ThemeData getThemeData(Brightness systemBrightness) {
    return AppThemes.getTheme(_currentPreset, systemBrightness);
  }
}
