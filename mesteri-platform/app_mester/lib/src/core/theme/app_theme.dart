import 'package:flutter/material.dart';

// === MESTERI CRAFTSMAN THEME SYSTEM ===
// Consistent design with craftsman-focused orange brand color

class MesteriColors {
  // Primary Craftsman Orange - Professional and energetic
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFE55A2B);
  static const Color primaryLight = Color(0xFFFF8A5C);

  // Semantic Colors
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);

  // Neutral Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color surfaceVariant = Color(0xFFE9ECEF);
  static const Color background = Color(0xFFFFFFFF);

  // Text Colors
  static const Color onSurface = Color(0xFF212529);
  static const Color onSurfaceSecondary = Color(0xFF6C757D);
  static const Color onSurfaceTertiary = Color(0xFFADB5BD);

  // Border and dividers
  static const Color outline = Color(0xFFCED4DA);
  static const Color divider = Color(0xFFDEE2E6);

  // Special Colors
  static const Color accent = Color(0xFF4ECDC4);
  static const Color rating = Color(0xFFFFD700); // gold color for ratings

  // Opacity variants
  static final Color primaryUltraLowOpacity = primary.withOpacity(0.04);
  static final Color primaryVeryLowOpacity = primary.withOpacity(0.1);
  static final Color primaryLowOpacity = primary.withOpacity(0.2);
  static final Color primaryHighOpacity = primary.withOpacity(0.3);

  static final Color successLowOpacity = success.withOpacity(0.1);
  static final Color successHighOpacity = success.withOpacity(0.2);

  static final Color warningVeryLowOpacity = warning.withOpacity(0.1);
  static final Color warningLowOpacity = warning.withOpacity(0.2);

  static final Color errorLowOpacity = error.withOpacity(0.2);
  static final Color errorVeryLowOpacity = error.withOpacity(0.1);
}

// Spacing constants for consistency
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class AppTheme {
  // Aliased to MesteriColors for backward compatibility
  static const Color primaryColor = MesteriColors.primary;
  static const Color primaryDark = MesteriColors.primaryDark;
  static const Color primaryLight = MesteriColors.primaryLight;

  // Surface Colors
  static const Color surfaceColor = MesteriColors.surfaceLight;
  static const Color onSurfaceColor = MesteriColors.onSurface;
  static const Color onSurfaceSecondary = MesteriColors.onSurfaceSecondary;
  static const Color backgroundColor = MesteriColors.background;
  static const Color surfaceVariant = MesteriColors.surfaceVariant;

  // Semantic Colors
  static const Color accentColor = MesteriColors.accent;
  static const Color success = MesteriColors.success;
  static const Color successColor = MesteriColors.success;
  static const Color warning = MesteriColors.warning;
  static const Color warningColor = MesteriColors.warning;
  static const Color errorColor = MesteriColors.error;
  static const Color info = MesteriColors.info;
  static const Color ratingColor = MesteriColors.rating;

  // Text Colors
  static const Color textPrimary = MesteriColors.onSurface;
  static const Color textSecondary = MesteriColors.onSurfaceSecondary;
  static const Color textDisabled = MesteriColors.onSurfaceTertiary;
  static const Color outlineColor = MesteriColors.outline;

  // Card & Divider
  static const Color cardColor = MesteriColors.surface;
  static const Color dividerColor = MesteriColors.divider;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MesteriColors.primary,
        primary: MesteriColors.primary,
        secondary: MesteriColors.accent,
        error: MesteriColors.error,
        surface: MesteriColors.surface,
        brightness: Brightness.light,
      ),
      primaryColor: MesteriColors.primary,
      scaffoldBackgroundColor: MesteriColors.surfaceLight,
      cardTheme: CardThemeData(
        color: MesteriColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: MesteriColors.surfaceLight,
        foregroundColor: MesteriColors.onSurface,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MesteriColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: MesteriColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
