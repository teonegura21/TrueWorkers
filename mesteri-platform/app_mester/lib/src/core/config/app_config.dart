// Configuration for the Mesteri Craftsman App
// Identical settings to Client App for consistency

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static const String appName = 'Mesteri Platform - Craftsman';
  static const String appVersion = '1.0.0';

  // API Configuration - Environment-aware
  static String get apiBaseUrl {
    const envApiUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envApiUrl.isNotEmpty) return envApiUrl;

    // Development/local default
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000'; // Android emulator
    } else {
      return 'http://localhost:3000';
    }
  }

  static const String apiVersion = 'v1';
  static String get wsBaseUrl => apiBaseUrl.replaceAll('http', 'ws');

  // App Settings
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const String currencySymbol = 'RON';

  // Service categories for job discovery
  static const List<String> serviceCategories = [
    'Instalații Sanitare',
    'Zugrăvit',
    'Gresie și Faianță',
    'Construcții',
    'Electrician',
    'Tapsitor',
    'Uscătorii',
    'Tâmplărie',
    'Parchet',
    'Montaj Mobilier',
    'Termopan',
    'Altele',
  ];
}
