import 'package:flutter/material.dart';

/// Second Brain Material 3 color scheme
/// Primary: Green (Google Keep inspired)
/// Secondary: Light Green
/// Accent: Amber
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryLighter = Color(0xFF81C784);
  static const Color secondary = Color(0xFF1B5E20);
  static const Color accent = Color(0xFFF57F17);
  static const Color accentLight = Color(0xFFFFC107);

  // Light theme surface colors
  static const Color lightBackground = Color(0xFFF8FAF8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEFF5EF);
  static const Color lightSurfaceContainer = Color(0xFFF3FAF3);
  static const Color lightOnSurface = Color(0xFF1A1C19);
  static const Color lightOnSurfaceVariant = Color(0xFF42493F);

  // Dark theme surface colors
  static const Color darkBackground = Color(0xFF0F1410);
  static const Color darkSurface = Color(0xFF1A1F1B);
  static const Color darkSurfaceVariant = Color(0xFF242A25);
  static const Color darkSurfaceContainer = Color(0xFF1E2520);
  static const Color darkOnSurface = Color(0xFFE2E3DE);
  static const Color darkOnSurfaceVariant = Color(0xFFC2C8BC);

  // Note card colors
  static const List<Color> noteCardColors = [
    Colors.transparent, // Default (uses surface)
    Color(0xFFFFCDD2), // Soft Red
    Color(0xFFFFE0B2), // Soft Orange
    Color(0xFFFFF9C4), // Soft Yellow
    Color(0xFFC8E6C9), // Soft Green
    Color(0xFFBBDEFB), // Soft Blue
    Color(0xFFE1BEE7), // Soft Purple
    Color(0xFFD7CCC8), // Soft Brown
    Color(0xFFCFD8DC), // Soft Grey
  ];

  // Dark note card colors
  static const List<Color> darkNoteCardColors = [
    Colors.transparent,
    Color(0xFF4A2329),
    Color(0xFF4A3523),
    Color(0xFF4A4423),
    Color(0xFF1E3D23),
    Color(0xFF1C3050),
    Color(0xFF3D2B4A),
    Color(0xFF3D302A),
    Color(0xFF2A313C),
  ];

  // Tag colors
  static const List<Color> tagColors = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFF44336),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFF795548),
    Color(0xFF607D8B),
    Color(0xFFE91E63),
    Color(0xFF009688),
  ];

  // Status colors
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFB00020);
  static const Color warning = Color(0xFFF57F17);
  static const Color info = Color(0xFF0277BD);
}

/// Light and Dark ColorScheme generators
class AppColorSchemes {
  AppColorSchemes._();

  static ColorScheme get light => ColorScheme.fromSeed(
    seedColor: AppColors.primaryLight,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFB8F5B8),
    onPrimaryContainer: const Color(0xFF002204),
    secondary: const Color(0xFF516350),
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFD3E8D1),
    onSecondaryContainer: const Color(0xFF0F1F10),
    tertiary: const Color(0xFF915D00),
    tertiaryContainer: const Color(0xFFFFDEA0),
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightOnSurface,
    surfaceContainerHighest: const Color(0xFFE2E9E0),
    outline: const Color(0xFF72796F),
    error: AppColors.error,
  );

  static ColorScheme get dark => ColorScheme.fromSeed(
    seedColor: AppColors.primaryLight,
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFF9DD89D),
    onPrimary: const Color(0xFF003909),
    primaryContainer: const Color(0xFF0A5217),
    onPrimaryContainer: const Color(0xFFB8F5B8),
    secondary: const Color(0xFFB7CCB5),
    onSecondary: const Color(0xFF233424),
    secondaryContainer: const Color(0xFF394B39),
    onSecondaryContainer: const Color(0xFFD3E8D1),
    tertiary: const Color(0xFFF7BC49),
    tertiaryContainer: const Color(0xFF6E4500),
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    surfaceContainerHighest: const Color(0xFF3B4239),
    outline: const Color(0xFF8C9389),
    error: const Color(0xFFCF6679),
  );
}
