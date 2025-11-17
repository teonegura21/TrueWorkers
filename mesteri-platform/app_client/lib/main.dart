import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'src/features/auth/presentation/screens/welcome_screen.dart';
import 'src/features/auth/presentation/screens/forgot_password_screen.dart';
import 'src/navigation/main_navigator.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/services/secure_storage_service.dart';
import 'services/notifications/push_notification_service.dart';
import 'handlers/notification_handler.dart';

// Global key to access context for navigation outside of widgets
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options (handle duplicate app gracefully)
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    // If Firebase is already initialized (by google-services.json), ignore the error
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }

  // Enable Firebase Auth persistence (users stay logged in) - only needed on web
  // On mobile (Android/iOS), persistence is enabled by default

  // Initialize push notifications
  await PushNotificationService().initialize(
    apiBaseUrl: 'http://localhost:3000/api', // This should match your backend URL
    onTap: (message) {
      // Handle notification tap when app is in foreground/background
      // We'll use a global key to access context, or use another navigation pattern
      print('Notification tapped: ${message.messageId}');
      
      // Navigate to the appropriate screen based on the notification
      if (navigatorKey.currentState != null) {
        NotificationHandler.handleNotificationTap(navigatorKey.currentState!.context, message);
      }
    },
  );

  runApp(const MesteriApp());
}

class MesteriApp extends StatelessWidget {
  const MesteriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mesteri Platform',
      theme: AppTheme.lightTheme,
      home: AuthStateHandler(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/main': (context) => const MainNavigator(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const WelcomeScreen());
      },
      navigatorKey: navigatorKey, // Add navigator key for global navigation
    );
  }
}

// Auth State Handler - automatically shows correct screen based on login state
// with session validation for security
class AuthStateHandler extends StatefulWidget {
  const AuthStateHandler({super.key});

  @override
  State<AuthStateHandler> createState() => _AuthStateHandlerState();
}

class _AuthStateHandlerState extends State<AuthStateHandler> {
  final SecureStorageService _storage = SecureStorageService();
  bool _isValidating = true;

  @override
  void initState() {
    super.initState();
    _validateSession();
  }

  /// Validate stored session on app start
  Future<void> _validateSession() async {
    try {
      final isValid = await _storage.isSessionValid();
      if (!isValid) {
        // Session expired, sign out
        await FirebaseAuth.instance.signOut();
        await _storage.clearAuthData();
      }
    } catch (e) {
      debugPrint('⚠️ Session validation error: $e');
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isValidating) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in, show main navigator
        if (snapshot.hasData && snapshot.data != null) {
          debugPrint('✅ User is logged in: ${snapshot.data!.email}');
          return const MainNavigator();
        }

        // If not logged in, show welcome screen
        debugPrint('🚪 No user logged in, showing welcome screen');
        return const WelcomeScreen();
      },
    );
  }
}
