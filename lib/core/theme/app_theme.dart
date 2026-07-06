import 'package:flutter/material.dart';

class WakeUpTheme {
  const WakeUpTheme._();

  static const darkBackground = Color(0xff070b1d);
  static const darkSurface = Color(0xff11183a);
  static const darkSurfaceHigh = Color(0xff182352);
  static const darkPrimary = Color(0xff2864ff);
  static const darkSecondary = Color(0xff8b7cff);
  static const darkTertiary = Color(0xff6ee7ff);

  static const lightBackground = Color(0xfff4f7ff);
  static const lightSurface = Color(0xffffffff);
  static const lightPrimary = Color(0xff2365f6);
  static const lightSecondary = Color(0xff6750d8);
  static const lightTertiary = Color(0xff0f8ea8);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: lightPrimary,
      brightness: Brightness.light,
    ).copyWith(
      primary: lightPrimary,
      secondary: lightSecondary,
      tertiary: lightTertiary,
      surface: lightSurface,
      surfaceContainerHighest: const Color(0xffe7edff),
      onSurface: const Color(0xff101827),
      onSurfaceVariant: const Color(0xff63708a),
    );

    return _base(
      scheme: scheme,
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightSurface,
      dividerColor: Colors.black.withValues(alpha: 0.08),
      textColor: const Color(0xff101827),
      isDark: false,
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: darkPrimary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: darkPrimary,
      secondary: darkSecondary,
      tertiary: darkTertiary,
      surface: darkSurface,
      surfaceContainerHighest: darkSurfaceHigh,
      onPrimary: Colors.white,
      onSurface: const Color(0xfff5f7ff),
      onSurfaceVariant: const Color(0xffa6b0d0),
      primaryContainer: const Color(0xff1f46b8),
      onPrimaryContainer: Colors.white,
      secondaryContainer: const Color(0xff2a255f),
      onSecondaryContainer: const Color(0xffe6e2ff),
    );

    return _base(
      scheme: scheme,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurface,
      dividerColor: Colors.white.withValues(alpha: 0.08),
      textColor: Colors.white,
      isDark: true,
    );
  }

  static ThemeData _base({
    required ColorScheme scheme,
    required Color scaffoldBackgroundColor,
    required Color cardColor,
    required Color dividerColor,
    required Color textColor,
    required bool isDark,
  }) {
    final cardRadius = BorderRadius.circular(8);
    final controlRadius = BorderRadius.circular(14);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: Typography.blackCupertino.apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scaffoldBackgroundColor,
        foregroundColor: textColor,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        shadowColor: scheme.primary.withValues(alpha: isDark ? 0.2 : 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: BorderSide(color: dividerColor),
        ),
      ),
      dividerColor: dividerColor,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(borderRadius: controlRadius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(48, 50),
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.45)),
          shape: RoundedRectangleBorder(borderRadius: controlRadius),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkSurfaceHigh : Colors.white,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: controlRadius,
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: controlRadius,
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: controlRadius,
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: scheme.primary.withValues(alpha: 0.18),
      ),
    );
  }
}
