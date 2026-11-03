import 'package:flutter/material.dart';

import '../../../domain/models/part_category.dart';

/// UI presentation metadata (icon and color) for each [PartCategory].
extension PartCategoryUiExtension on PartCategory {
  IconData get icon => switch (this) {
        PartCategory.resistors => Icons.linear_scale,
        PartCategory.capacitors => Icons.battery_charging_full,
        PartCategory.inductors => Icons.all_inclusive,
        PartCategory.icsAndMcus => Icons.memory,
        PartCategory.semiconductors => Icons.electrical_services,
        PartCategory.ledsAndDisplays => Icons.lightbulb_outline,
        PartCategory.sensors => Icons.sensors,
        PartCategory.connectors => Icons.settings_input_component,
        PartCategory.powerAndModules => Icons.bolt,
        PartCategory.electromechanical => Icons.toggle_on_outlined,
        PartCategory.other => Icons.category_outlined,
      };

  Color get color => switch (this) {
        PartCategory.resistors => const Color(0xFFD97706),
        PartCategory.capacitors => const Color(0xFF2563EB),
        PartCategory.inductors => const Color(0xFF7C3AED),
        PartCategory.icsAndMcus => const Color(0xFF059669),
        PartCategory.semiconductors => const Color(0xFFDC2626),
        PartCategory.ledsAndDisplays => const Color(0xFFEAB308),
        PartCategory.sensors => const Color(0xFF0891B2),
        PartCategory.connectors => const Color(0xFF4F46E5),
        PartCategory.powerAndModules => const Color(0xFFEA580C),
        PartCategory.electromechanical => const Color(0xFF475569),
        PartCategory.other => const Color(0xFF64748B),
      };
}

/// Provides Light and Dark Material 3 themes with an iOS-friendly visual style.
class AppTheme {
  static const Color _seedColor = Color(0xFF0F766E); // PCB Teal

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF4F6F8),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF4F6F8),
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0B1116),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0B1116),
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF151E26),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF151E26),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
    );
  }
}
