import 'package:flutter/material.dart';

@immutable
class QashThemeExtension extends ThemeExtension<QashThemeExtension> {
  const QashThemeExtension({
    required this.scaffoldBackground,
    required this.surface,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.primaryButton,
    required this.onPrimaryButton,
    required this.accent,
    required this.onAccent,
    required this.danger,
    required this.border,
    required this.iconMuted,
    required this.cardShadow,
    required this.navBarBackground,
    required this.navBarBorder,
  });

  final Color scaffoldBackground;
  final Color surface;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color primaryButton;
  final Color onPrimaryButton;
  final Color accent;
  final Color onAccent;
  final Color danger;
  final Color border;
  final Color iconMuted;
  final Color cardShadow;
  final Color navBarBackground;
  final Color navBarBorder;

  static const light = QashThemeExtension(
    scaffoldBackground: Color(0xFFF7F6F3),
    surface: Colors.white,
    surfaceElevated: Colors.white,
    textPrimary: Color(0xFF111111),
    textSecondary: Color(0xFF8B8B8B),
    textHint: Color(0xFFC4C4C4),
    primaryButton: Color(0xFF111111),
    onPrimaryButton: Colors.white,
    accent: Color(0xFFF4D93A),
    onAccent: Color(0xFF111111),
    danger: Color(0xFFEF4444),
    border: Color(0xFFE5E7EB),
    iconMuted: Color(0xFF8B8B8B),
    cardShadow: Color(0x19000000),
    navBarBackground: Colors.white,
    navBarBorder: Color(0xFFF3F4F6),
  );

  static const dark = QashThemeExtension(
    scaffoldBackground: Color(0xFF0F1115),
    surface: Color(0xFF1A1D24),
    surfaceElevated: Color(0xFF23272F),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFB0B3B8),
    textHint: Color(0xFF6B7280),
    primaryButton: Color(0xFFF4D93A),
    onPrimaryButton: Color(0xFF111111),
    accent: Color(0xFFF4D93A),
    onAccent: Color(0xFF111111),
    danger: Color(0xFFF87171),
    border: Color(0xFF2D323C),
    iconMuted: Color(0xFF9CA3AF),
    cardShadow: Color(0x66000000),
    navBarBackground: Color(0xFF1A1D24),
    navBarBorder: Color(0xFF2D323C),
  );

  @override
  QashThemeExtension copyWith({
    Color? scaffoldBackground,
    Color? surface,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? primaryButton,
    Color? onPrimaryButton,
    Color? accent,
    Color? onAccent,
    Color? danger,
    Color? border,
    Color? iconMuted,
    Color? cardShadow,
    Color? navBarBackground,
    Color? navBarBorder,
  }) {
    return QashThemeExtension(
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      primaryButton: primaryButton ?? this.primaryButton,
      onPrimaryButton: onPrimaryButton ?? this.onPrimaryButton,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      danger: danger ?? this.danger,
      border: border ?? this.border,
      iconMuted: iconMuted ?? this.iconMuted,
      cardShadow: cardShadow ?? this.cardShadow,
      navBarBackground: navBarBackground ?? this.navBarBackground,
      navBarBorder: navBarBorder ?? this.navBarBorder,
    );
  }

  @override
  QashThemeExtension lerp(ThemeExtension<QashThemeExtension>? other, double t) {
    if (other is! QashThemeExtension) return this;
    return t < 0.5 ? this : other;
  }
}

extension QashThemeContext on BuildContext {
  QashThemeExtension get qash =>
      Theme.of(this).extension<QashThemeExtension>() ?? QashThemeExtension.light;
}
