import 'package:flutter/material.dart';

// === MESTERI CLIENT THEME SYSTEM ===
// Identical brand colors and trust-first design across client & craftsman apps

class MesteriColors {
  // Primary Trust Blue - Used for all CTAs and trust indicators
  static const Color primary = Color(0xFF4C6EF5);
  static const Color primaryDark = Color(0xFF364FC7);
  static const Color primaryLight = Color(0xFFE9EDFF);

  // Secondary Premium Gold - For premium features and badges
  static const Color secondary = Color(0xFFFF7F50);
  static const Color secondaryAlt = Color(0xFF00B4D8);

  // Semantic Colors - Used consistently for status and feedback
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);

  // Neutral Colors - Exactly the same foundation
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F6FA);
  static const Color surfaceVariant = Color(0xFFF0F1F5);

  // Text colors - Consistent hierarchy
  static const Color onSurface = Color(0xFF12131A);
  static const Color onSurfaceSecondary = Color(0xFF505465);
  static const Color onSurfaceTertiary = Color(0xFF8B8FA1);

  // Border and dividers
  static const Color outline = Color(0xFFE0E2EB);

  // === OPACITY VARIANTS USING withOpacity() FOR PRECISION ===

  // Primary opacity variants
  static final Color primaryUltraLowOpacity = primary.withOpacity(0.04);
  static final Color primaryVeryLowOpacity = primary.withOpacity(0.08);
  static final Color primaryLowOpacity = primary.withOpacity(0.16);
  static final Color primaryHighOpacity = primary.withOpacity(0.28);

  // Secondary opacity variants
  static final Color secondaryLowOpacity = secondary.withOpacity(0.18);
  static final Color secondaryHighOpacity = secondary.withOpacity(0.3);

  // Success opacity variants
  static final Color successLowOpacity = success.withOpacity(0.1);
  static final Color successVeryLowOpacity = success.withOpacity(0.05);
  static final Color successHighOpacity = success.withOpacity(0.2);

  // Warning opacity variants
  static final Color warningLowOpacity = warning.withOpacity(0.1);
  static final Color warningVeryLowOpacity = warning.withOpacity(0.05);
  static final Color warningHighOpacity = warning.withOpacity(0.2);

  // Error opacity variants
  static final Color errorLowOpacity = error.withOpacity(0.1);

  // Outline opacity variants
  static final Color outlineMediumOpacity = outline.withOpacity(0.3);

  // Standard opacity variants for extended colors
  static final Color blackLowOpacity = Color.fromRGBO(0, 0, 0, 0.05);
  static final Color blackMediumOpacity = Color.fromRGBO(0, 0, 0, 0.1);
}

// === TRUST SYSTEM DECORATIONS - USED BY TRUSTBADGE COMPONENT ===

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class TrustDecorations {
  static BoxDecoration verified = BoxDecoration(
    color: MesteriColors.primaryLowOpacity,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: MesteriColors.primary, width: 1),
  );

  static BoxDecoration premium = BoxDecoration(
    gradient: LinearGradient(
      colors: [MesteriColors.secondary, MesteriColors.secondaryLowOpacity],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: MesteriColors.secondaryHighOpacity,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration secure = BoxDecoration(
    color: MesteriColors.successLowOpacity,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: MesteriColors.success, width: 1),
  );
}

// === APP THEME CLASS ===
// Consolidated to use MesteriColors only

class AppTheme {
  // === BRAND COLORS - ALIASED TO MESTERI COLORS FOR COMPATIBILITY ===
  // Use MesteriColors.primary directly in new code
  static const Color primaryColor = MesteriColors.primary;
  static const Color primaryDark = MesteriColors.primaryDark;
  static const Color primaryLight = MesteriColors.primaryLight;
  static const Color secondaryColor = MesteriColors.secondary;
  static const Color accentColor = MesteriColors.secondary;
  static const Color successColor = MesteriColors.success;
  static const Color warningColor = MesteriColors.warning;
  static const Color errorColor = MesteriColors.error;
  static const Color onSurfaceColor = MesteriColors.onSurface;
  static const Color onSurfaceSecondary = MesteriColors.onSurfaceSecondary;
  static const Color onSurfaceTertiary = MesteriColors.onSurfaceTertiary;

  // Surface colors
  static const Color surfaceColor = MesteriColors.surface;
  static const Color surfaceVariant = MesteriColors.surfaceVariant;
  static const Color backgroundColor = MesteriColors.background;
  static const Color outlineColor = MesteriColors.outline;

  // Opacity variants - aliased to MesteriColors
  static final Color primaryUltraLowOpacity = MesteriColors.primaryUltraLowOpacity;
  static final Color primaryVeryLowOpacity = MesteriColors.primaryVeryLowOpacity;
  static final Color primaryLowOpacity = MesteriColors.primaryLowOpacity;
  static final Color primaryHighOpacity = MesteriColors.primaryHighOpacity;
  static final Color successLowOpacity = MesteriColors.successLowOpacity;
  static final Color successVeryLowOpacity = MesteriColors.successVeryLowOpacity;
  static final Color successHighOpacity = MesteriColors.successHighOpacity;
  static final Color warningLowOpacity = MesteriColors.warningLowOpacity;
  static final Color warningHighOpacity = MesteriColors.warningHighOpacity;
  static final Color errorLowOpacity = MesteriColors.errorLowOpacity;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MesteriColors.primary,
        primary: MesteriColors.primary,
        secondary: MesteriColors.secondary,
        error: MesteriColors.error,
        surface: MesteriColors.surface,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: MesteriColors.background,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: MesteriColors.primary,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MesteriColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: MesteriColors.surfaceVariant,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MesteriColors.primary,
        primary: MesteriColors.primary,
        secondary: MesteriColors.secondary,
        error: MesteriColors.error,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }
}

// === HELPER FUNCTIONS - FOR TRUST SYSTEM ===
class TrustBadgeHelper {
  static BoxDecoration getDecoration({
    bool isVerified = false,
    bool isPremium = false,
  }) {
    if (isPremium) return TrustDecorations.premium;
    if (isVerified) return TrustDecorations.verified;
    return TrustDecorations.secure;
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'pending':
        return MesteriColors.primary;
      case 'completed':
      case 'verified':
        return MesteriColors.success;
      case 'cancelled':
      case 'rejected':
        return MesteriColors.error;
      case 'disputed':
      case 'warning':
        return MesteriColors.warning;
      default:
        return MesteriColors.onSurfaceSecondary;
    }
  }
}
