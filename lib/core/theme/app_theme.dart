import 'package:flutter/material.dart';

enum AppThemePreset {
  system('System', 'Follows device appearance', Icons.brightness_auto),
  googleLight('Google Light', 'Clean white with Google blue', Icons.light_mode),
  googleDark('Google Dark', 'Balanced dark with soft blue', Icons.dark_mode),
  graphite('Graphite', 'Monochrome charcoal, gray & white', Icons.lens),
  sage('Sage', 'Muted natural green & warm neutrals', Icons.eco),
  sand('Sand', 'Warm beige, cream & earthy tones', Icons.grain),
  rose('Rose', 'Dusty rose & soft blush neutrals', Icons.local_florist),
  ocean('Ocean', 'Teal-blue & cool slate neutrals', Icons.water);

  final String label;
  final String description;
  final IconData icon;

  const AppThemePreset(this.label, this.description, this.icon);

  static AppThemePreset fromString(String? value) {
    return AppThemePreset.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppThemePreset.system,
    );
  }
}

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color keepColor;
  final Color deleteColor;
  final Color warningColor;
  final Color subtleText;
  final Color cardBorder;
  final Color chipBackground;
  final Color overlayPill;

  const AppThemeColors({
    required this.keepColor,
    required this.deleteColor,
    required this.warningColor,
    required this.subtleText,
    required this.cardBorder,
    required this.chipBackground,
    required this.overlayPill,
  });

  @override
  AppThemeColors copyWith({
    Color? keepColor,
    Color? deleteColor,
    Color? warningColor,
    Color? subtleText,
    Color? cardBorder,
    Color? chipBackground,
    Color? overlayPill,
  }) {
    return AppThemeColors(
      keepColor: keepColor ?? this.keepColor,
      deleteColor: deleteColor ?? this.deleteColor,
      warningColor: warningColor ?? this.warningColor,
      subtleText: subtleText ?? this.subtleText,
      cardBorder: cardBorder ?? this.cardBorder,
      chipBackground: chipBackground ?? this.chipBackground,
      overlayPill: overlayPill ?? this.overlayPill,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      keepColor: Color.lerp(keepColor, other.keepColor, t)!,
      deleteColor: Color.lerp(deleteColor, other.deleteColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
      overlayPill: Color.lerp(overlayPill, other.overlayPill, t)!,
    );
  }
}

class AppThemes {
  // 1. Google Light
  static ThemeData get googleLight {
    const primary = Color(0xFF1A73E8);
    const surface = Color(0xFFFFFFFF);
    const surfaceContainer = Color(0xFFF8F9FA);
    const surfaceContainerHigh = Color(0xFFF1F3F4);
    const onSurface = Color(0xFF202124);
    const subtle = Color(0xFF5F6368);

    return _buildTheme(
      brightness: Brightness.light,
      primary: primary,
      surface: surface,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      onSurface: onSurface,
      outline: const Color(0xFFDADCE0),
      outlineVariant: const Color(0xFFE8EAED),
      appColors: const AppThemeColors(
        keepColor: Color(0xFF1E8E3E),
        deleteColor: Color(0xFFD93025),
        warningColor: Color(0xFFF9AB00),
        subtleText: subtle,
        cardBorder: Color(0xFFE8EAED),
        chipBackground: Color(0xFFF1F3F4),
        overlayPill: Color(0xE6202124),
      ),
    );
  }

  // 2. Google Dark
  static ThemeData get googleDark {
    const primary = Color(0xFF8AB4F8);
    const surface = Color(0xFF121212);
    const surfaceContainer = Color(0xFF1E1E1E);
    const surfaceContainerHigh = Color(0xFF2D2E30);
    const onSurface = Color(0xFFE8EAED);
    const subtle = Color(0xFF9AA0A6);

    return _buildTheme(
      brightness: Brightness.dark,
      primary: primary,
      surface: surface,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      onSurface: onSurface,
      outline: const Color(0xFF3C4043),
      outlineVariant: const Color(0xFF282A2D),
      appColors: const AppThemeColors(
        keepColor: Color(0xFF81C995),
        deleteColor: Color(0xFFF28B82),
        warningColor: Color(0xFFFDD663),
        subtleText: subtle,
        cardBorder: Color(0xFF3C4043),
        chipBackground: Color(0xFF2D2E30),
        overlayPill: Color(0xE61E1E1E),
      ),
    );
  }

  // 3. Graphite (Monochrome Charcoal)
  static ThemeData get graphite {
    const primary = Color(0xFFE5E5EA);
    const surface = Color(0xFF18181B);
    const surfaceContainer = Color(0xFF27272A);
    const surfaceContainerHigh = Color(0xFF3F3F46);
    const onSurface = Color(0xFFFAFAFA);
    const subtle = Color(0xFFA1A1AA);

    return _buildTheme(
      brightness: Brightness.dark,
      primary: primary,
      surface: surface,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      onSurface: onSurface,
      outline: const Color(0xFF52525B),
      outlineVariant: const Color(0xFF3F3F46),
      appColors: const AppThemeColors(
        keepColor: Color(0xFFA7F3D0),
        deleteColor: Color(0xFFFECACA),
        warningColor: Color(0xFFFDE68A),
        subtleText: subtle,
        cardBorder: Color(0xFF3F3F46),
        chipBackground: Color(0xFF27272A),
        overlayPill: Color(0xE618181B),
      ),
    );
  }

  // 4. Sage (Muted natural green)
  static ThemeData get sage {
    const primary = Color(0xFF3B6E4C);
    const surface = Color(0xFFF7F9F6);
    const surfaceContainer = Color(0xFFEFF3EE);
    const surfaceContainerHigh = Color(0xFFE3EAE1);
    const onSurface = Color(0xFF1B231D);
    const subtle = Color(0xFF5A665D);

    return _buildTheme(
      brightness: Brightness.light,
      primary: primary,
      surface: surface,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      onSurface: onSurface,
      outline: const Color(0xFFCBD6CC),
      outlineVariant: const Color(0xFFDFE6DF),
      appColors: const AppThemeColors(
        keepColor: Color(0xFF2D6A4F),
        deleteColor: Color(0xFFC84B31),
        warningColor: Color(0xFFD4A373),
        subtleText: subtle,
        cardBorder: Color(0xFFDFE6DF),
        chipBackground: Color(0xFFEFF3EE),
        overlayPill: Color(0xE61B231D),
      ),
    );
  }

  // 5. Sand (Warm beige & earthy accents)
  static ThemeData get sand {
    const primary = Color(0xFF8D6E53);
    const surface = Color(0xFFFAF7F2);
    const surfaceContainer = Color(0xFFF3EFE8);
    const surfaceContainerHigh = Color(0xFFE9E2D8);
    const onSurface = Color(0xFF2D251E);
    const subtle = Color(0xFF756758);

    return _buildTheme(
      brightness: Brightness.light,
      primary: primary,
      surface: surface,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      onSurface: onSurface,
      outline: const Color(0xFFD6CBC0),
      outlineVariant: const Color(0xFFE6DEC3),
      appColors: const AppThemeColors(
        keepColor: Color(0xFF49654C),
        deleteColor: Color(0xFFBA4B3E),
        warningColor: Color(0xFFD49B45),
        subtleText: subtle,
        cardBorder: Color(0xFFE6DEC3),
        chipBackground: Color(0xFFF3EFE8),
        overlayPill: Color(0xE62D251E),
      ),
    );
  }

  // 6. Rose (Muted dusty rose)
  static ThemeData get rose {
    const primary = Color(0xFF9E4B65);
    const surface = Color(0xFFFAF5F6);
    const surfaceContainer = Color(0xFFF5EBED);
    const surfaceContainerHigh = Color(0xFFECDFE2);
    const onSurface = Color(0xFF281E21);
    const subtle = Color(0xFF736166);

    return _buildTheme(
      brightness: Brightness.light,
      primary: primary,
      surface: surface,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      onSurface: onSurface,
      outline: const Color(0xFFDBCAD0),
      outlineVariant: const Color(0xFFEAE0E3),
      appColors: const AppThemeColors(
        keepColor: Color(0xFF3E755E),
        deleteColor: Color(0xFFBF3A4B),
        warningColor: Color(0xFFC78B43),
        subtleText: subtle,
        cardBorder: Color(0xFFEAE0E3),
        chipBackground: Color(0xFFF5EBED),
        overlayPill: Color(0xE6281E21),
      ),
    );
  }

  // 7. Ocean (Teal-blue with cool slate)
  static ThemeData get ocean {
    const primary = Color(0xFF1E6091);
    const surface = Color(0xFFF2F6F9);
    const surfaceContainer = Color(0xFFE6EEF4);
    const surfaceContainerHigh = Color(0xFFD8E4ED);
    const onSurface = Color(0xFF142129);
    const subtle = Color(0xFF566978);

    return _buildTheme(
      brightness: Brightness.light,
      primary: primary,
      surface: surface,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      onSurface: onSurface,
      outline: const Color(0xFFBCCDD8),
      outlineVariant: const Color(0xFFD2E0E9),
      appColors: const AppThemeColors(
        keepColor: Color(0xFF2E7D5B),
        deleteColor: Color(0xFFC44536),
        warningColor: Color(0xFFDB9D47),
        subtleText: subtle,
        cardBorder: Color(0xFFD2E0E9),
        chipBackground: Color(0xFFE6EEF4),
        overlayPill: Color(0xE6142129),
      ),
    );
  }

  static ThemeData getTheme(AppThemePreset preset, [Brightness systemBrightness = Brightness.light]) {
    switch (preset) {
      case AppThemePreset.system:
        return systemBrightness == Brightness.dark ? googleDark : googleLight;
      case AppThemePreset.googleLight:
        return googleLight;
      case AppThemePreset.googleDark:
        return googleDark;
      case AppThemePreset.graphite:
        return graphite;
      case AppThemePreset.sage:
        return sage;
      case AppThemePreset.sand:
        return sand;
      case AppThemePreset.rose:
        return rose;
      case AppThemePreset.ocean:
        return ocean;
    }
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color surface,
    required Color surfaceContainer,
    required Color surfaceContainerHigh,
    required Color onSurface,
    required Color outline,
    required Color outlineVariant,
    required AppThemeColors appColors,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: brightness == Brightness.dark ? const Color(0xFF121212) : Colors.white,
      secondary: primary,
      onSecondary: brightness == Brightness.dark ? const Color(0xFF121212) : Colors.white,
      error: appColors.deleteColor,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      outline: outline,
      outlineVariant: outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      cardColor: surfaceContainer,
      canvasColor: surface,
      dividerColor: outlineVariant,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: onSurface, size: 24),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: appColors.subtleText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 12);
          }
          return TextStyle(color: appColors.subtleText, fontWeight: FontWeight.w500, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary, size: 24);
          }
          return IconThemeData(color: appColors.subtleText, size: 24);
        }),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: appColors.cardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: appColors.subtleText.withValues(alpha: 0.4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: brightness == Brightness.dark ? const Color(0xFF121212) : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: outline),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      extensions: [appColors],
    );
  }
}

extension AppThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ??
      const AppThemeColors(
        keepColor: Color(0xFF1E8E3E),
        deleteColor: Color(0xFFD93025),
        warningColor: Color(0xFFF9AB00),
        subtleText: Color(0xFF5F6368),
        cardBorder: Color(0xFFE8EAED),
        chipBackground: Color(0xFFF1F3F4),
        overlayPill: Color(0xE6202124),
      );
}
