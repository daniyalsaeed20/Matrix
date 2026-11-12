import 'package:flutter/material.dart';

/// Minimal locked theme — fixtures must consume these tokens, not hard-code colors.
abstract final class AppTheme {
  static const Color seed = Color(0xFF1B4D3E);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: seed);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      textTheme: Typography.material2021().black.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
