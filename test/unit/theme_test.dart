import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaspace/core/theme/app_theme.dart';
import 'package:lumaspace/core/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Theme Tests', () {
    test('All 7 themes plus system mode exist with distinct definitions', () {
      expect(AppThemePreset.values.length, 8);

      final presets = [
        AppThemePreset.system,
        AppThemePreset.googleLight,
        AppThemePreset.googleDark,
        AppThemePreset.graphite,
        AppThemePreset.sage,
        AppThemePreset.sand,
        AppThemePreset.rose,
        AppThemePreset.ocean,
      ];

      for (final preset in presets) {
        expect(AppThemePreset.values.contains(preset), true);
        final theme = AppThemes.getTheme(preset, Brightness.light);
        expect(theme, isNotNull);
        expect(theme.colorScheme.primary, isNotNull);

        final ext = theme.extension<AppThemeColors>();
        expect(ext, isNotNull);
        expect(ext?.keepColor, isNotNull);
        expect(ext?.deleteColor, isNotNull);
      }
    });

    test('System mode adapts to platform brightness', () {
      final lightSystem = AppThemes.getTheme(AppThemePreset.system, Brightness.light);
      final darkSystem = AppThemes.getTheme(AppThemePreset.system, Brightness.dark);

      expect(lightSystem.brightness, Brightness.light);
      expect(darkSystem.brightness, Brightness.dark);
    });

    test('ThemeProvider changes and persists theme selection', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final themeProvider = ThemeProvider(prefs);

      expect(themeProvider.currentPreset, AppThemePreset.system);

      await themeProvider.setThemePreset(AppThemePreset.ocean);
      expect(themeProvider.currentPreset, AppThemePreset.ocean);

      // Verify persistence in shared preferences
      expect(prefs.getString('lumaspace_theme_preset'), 'ocean');
    });
  });
}
