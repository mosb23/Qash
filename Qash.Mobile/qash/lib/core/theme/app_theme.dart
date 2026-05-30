import 'package:flutter/material.dart';

import 'qash_theme_extension.dart';

class AppTheme {
  static ThemeData get light => _buildTheme(
    brightness: Brightness.light,
    extension: QashThemeExtension.light,
  );

  static ThemeData get dark => _buildTheme(
    brightness: Brightness.dark,
    extension: QashThemeExtension.dark,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required QashThemeExtension extension,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: extension.scaffoldBackground,
      primaryColor: extension.primaryButton,
      extensions: [extension],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: extension.primaryButton,
        onPrimary: extension.onPrimaryButton,
        secondary: extension.accent,
        onSecondary: extension.onAccent,
        error: extension.danger,
        onError: Colors.white,
        surface: extension.surface,
        onSurface: extension.textPrimary,
        onSurfaceVariant: extension.textSecondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: extension.scaffoldBackground,
        foregroundColor: extension.textPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: extension.textPrimary),
        titleTextStyle: TextStyle(
          color: extension.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
      cardTheme: CardThemeData(
        color: extension.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(color: extension.border),
      iconTheme: IconThemeData(color: extension.textPrimary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return extension.onPrimaryButton;
          }
          return extension.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return extension.primaryButton;
          }
          return extension.border;
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: extension.primaryButton,
          foregroundColor: extension.onPrimaryButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: extension.textPrimary,
          side: BorderSide(color: extension.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: extension.surface,
        hintStyle: TextStyle(color: extension.textHint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? extension.surfaceElevated
            : extension.textPrimary,
        contentTextStyle: TextStyle(
          color: isDark ? extension.textPrimary : extension.onPrimaryButton,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: extension.surface,
        titleTextStyle: TextStyle(
          color: extension.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        contentTextStyle: TextStyle(
          color: extension.textSecondary,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: extension.surfaceElevated,
        textStyle: TextStyle(color: extension.textPrimary),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: extension.textPrimary,
          fontFamily: 'Inter',
        ),
        displayMedium: TextStyle(
          color: extension.textPrimary,
          fontFamily: 'Inter',
        ),
        displaySmall: TextStyle(
          color: extension.textPrimary,
          fontFamily: 'Inter',
        ),
        headlineLarge: TextStyle(
          color: extension.textPrimary,
          fontFamily: 'Inter',
        ),
        headlineMedium: TextStyle(
          color: extension.textPrimary,
          fontFamily: 'Inter',
        ),
        headlineSmall: TextStyle(
          color: extension.textPrimary,
          fontFamily: 'Inter',
        ),
        titleLarge: TextStyle(
          color: extension.textPrimary,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: extension.textPrimary,
          fontFamily: 'Inter',
        ),
        titleSmall: TextStyle(
          color: extension.textPrimary,
          fontFamily: 'Inter',
        ),
        bodyLarge: TextStyle(color: extension.textPrimary, fontFamily: 'Inter'),
        bodyMedium: TextStyle(
          color: extension.textPrimary,
          fontFamily: 'Inter',
        ),
        bodySmall: TextStyle(
          color: extension.textSecondary,
          fontFamily: 'Inter',
        ),
        labelLarge: TextStyle(
          color: extension.textSecondary,
          fontFamily: 'Inter',
        ),
        labelMedium: TextStyle(
          color: extension.textSecondary,
          fontFamily: 'Inter',
        ),
        labelSmall: TextStyle(color: extension.textHint, fontFamily: 'Inter'),
      ),
    );
  }
}
