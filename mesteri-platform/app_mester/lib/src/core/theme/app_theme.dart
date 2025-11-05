import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFE55A2B);
  static const Color primaryLight = Color(0xFFFF8A5C);

  // Surface Colors
  static const Color surfaceColor = Color(0xFFF8F9FA);
  static const Color onSurfaceColor = Color(0xFF212529);
  static const Color onSurfaceSecondary = Color(0xFF6C757D);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE9ECEF);

  // Accent Colors
  static const Color accentColor = Color(0xFF4ECDC4);
  static const Color success = Color(0xFF28A745);
  static const Color successColor = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);
  static const Color ratingColor = Color(0xFFFFD700); // gold color for ratings

  // Text Colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textDisabled = Color(0xFFADB5BD);
  static const Color outlineColor = Color(0xFFCED4DA);

  // Card & Divider
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFDEE2E6);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: surfaceColor,
      cardTheme: const CardThemeData(
        color: cardColor,
        elevation: 2,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class MesteriColors {
  static const Color primary = Color(0xFFFF6B35);
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color primaryLowOpacity = Color.fromARGB(51, 255, 107, 53); // 20% opacity of primary
  static const Color primaryVeryLowOpacity = Color.fromARGB(26, 255, 107, 53); // 10% opacity of primary
  static const Color onSurfaceSecondary = Color(0xFF6C757D);
  static const Color warningVeryLowOpacity = Color.fromARGB(26, 255, 193, 7); // 10% opacity of warning
  static const Color errorLowOpacity = Color.fromARGB(51, 220, 53, 69); // 20% opacity of error
}
