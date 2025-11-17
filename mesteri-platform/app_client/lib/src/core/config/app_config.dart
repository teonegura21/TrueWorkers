// App Configuration for Mesteri Platform
// Defines static configuration values for the application

class AppConfig {
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  // Pagination Configuration
  static const int defaultPageSize = 20;

  // Mock Data Toggle
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: true, // Default to true for development
  );

  // Job Categories for dropdown selection
  static const List<String> jobCategories = [
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

  // Major Romanian Cities for location selection
  static const List<String> majorRomanianCities = [
    'București',
    'Cluj-Napoca',
    'Timișoara',
    'Iași',
    'Constanța',
    'Brașov',
    'Oradea',
    'Ploiești',
    'Galați',
    'Brăila',
    'Arad',
    'Sibiu',
    'Târgu Mureș',
    'Baia Mare',
    'Botoșani',
    'Satu Mare',
    'Suceava',
    'Râmnicu Vâlcea',
    'Pitești',
    'Craiova',
    'Tulcea',
    'Buzău',
    'Bacău',
    'Slatina',
    'Focșani',
    'Giurgiu',
    'Piatra Neamț',
    'Târgoviște',
    'Bistrița',
    'Zalău',
    'Miercurea Ciuc',
    'Deva',
    'Târgu Jiu',
    'Reșița',
    'Hunedoara',
    'Sfântu Gheorghe',
    'Alba Iulia',
    'Turda',
    'Mediaș',
    'Onești',
    'Roman',
    'Câmpina',
    'Sighetu Marmației',
    'Petroșani',
    'Odorheiu Secuiesc',
    'Carei',
    'Lugoj',
    'Mangalia',
    'Câmpulung',
    'Dej',
  ];

  // Job urgency levels
  static const List<String> urgencyLevels = [
    'Normal',
    'Urgent (în 24h)',
    'Urgent (în 3-7 zile)',
    'Ocazie specială',
  ];

  // Budget range options
  static const List<Map<String, dynamic>> budgetRanges = [
    {'label': 'Sub 500 RON', 'min': 0, 'max': 500},
    {'label': '500 - 1000 RON', 'min': 500, 'max': 1000},
    {'label': '1000 - 2000 RON', 'min': 1000, 'max': 2000},
    {'label': '2000 - 5000 RON', 'min': 2000, 'max': 5000},
    {'label': 'Peste 5000 RON', 'min': 5000, 'max': double.infinity},
  ];

  // Currency configuration
  static const String currencySymbol = 'RON'; // Romanian Leu
  static const String currencyCode = 'RON';

  // App version
  static const String appVersion = '1.0.0';

  // App name
  static const String appName = 'Mesteri Platform';

  // Cache Configuration
  static const int cacheMaxAgeMinutes = 30; // Default cache time of 30 minutes

  // Feature flags
  static const bool enableLiveChat = true;
  static const bool enablePushNotifications = true;
  static const bool enableInAppPayments = true;
  static const bool enableUserReviews = true;
  static const bool enableJobPosting = true;
  static const bool enableCraftsmanVerification = true;
}